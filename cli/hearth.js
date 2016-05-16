'use strict';

const Datastore = require('nedb');
const electron = require('electron');
const uuid = require('node-uuid');
const Promise = require('bluebird');
const jsonminify = require("jsonminify");
const fs = Promise.promisifyAll(require('fs'));
const path = require('path');
const files = Promise.promisify(require('node-dir').files);
const term = require('./models/term').forPlatform();

let processes = {},
  resetTray,
  db = {
    apps: Promise.promisifyAll(new Datastore({
      filename: path.resolve(__dirname, '..', 'hearth.nedb.json'),
      autoload: true
    }))
  },
  binaries = {
    ember: path.join(__dirname, '..', 'node_modules', 'ember-cli', 'bin', 'ember'),
    npm: path.join(__dirname, '..', 'node_modules', 'npm', 'bin', 'npm-cli.js')
  };

function pathIsTransform(path) {
  return path.indexOf('/app/transforms/') === 0;
}

function pathToBinary(bin) {
  return binaries[bin];
}

function isEmberProject(projectPath) {
  const packagePath = path.join(projectPath, 'package.json');

  return fs.statAsync(packagePath)
    .then((stat) => stat.isFile() ? fs.readFileAsync(packagePath) : Promise.reject())
    .then((data) => {
      const pkg = JSON.parse(data);

      const isEmberProject = pkg.devDependencies.hasOwnProperty('ember-cli') ||
        pkg.dependencies.hasOwnProperty('ember-cli') ||
        pkg.optionalDependencies.hasOwnProperty('ember-cli') ||
        pkg.bundleDependencies.hasOwnProperty('ember-cli') ||
        pkg.peerDependencies.hasOwnProperty('ember-cli');

      return isEmberProject ? isEmberProject : Promise.reject();
    });
}

function addMetadata(project) {
  // get some app metadata (could probably be cached, but avoids old entries if stored in db on add)
  console.log('stat', path.resolve(project.data.attributes.path, 'package.json'));
  const packagePath = path.resolve(project.data.attributes.path, 'package.json');
  const cliPath = path.resolve(project.data.attributes.path, '.ember-cli');
  const appPath = path.resolve(project.data.attributes.path, 'app');

  return Promise.props({
    'package': fs.statAsync(packagePath),
    'cli': fs.statAsync(cliPath),
    'app': files(appPath)
  }).then((stats) => {
    return Promise.props({
      'package': stats.package.isFile() && fs.readFileAsync(packagePath),
      cli: stats.cli.isFile() && fs.readFileAsync(cliPath)
    }).then(data => {
      if (data.package) project.data.attributes.package = JSON.parse(data.package);
      if (data.cli) project.data.attributes.cli = JSON.parse(jsonminify(data.cli.toString('utf8')));

      // TODO: read default ports
      if (!project.data.attributes.cli) project.data.attributes.cli = {};
      if (!project.data.attributes.cli.testPort) project.data.attributes.cli.testPort = 7357;
      if (!project.data.attributes.cli.port) project.data.attributes.cli.port = 4200;

      project.data.attributes.transforms = stats.app.map(path => path.substring(project.data.attributes.path.length))
        .filter(pathIsTransform);

      return project;
    });
  });
}

var trayApps = [];

function ready(app, window) {
  const Tray = electron.Tray;
  const Menu = electron.Menu;
  let tray = new Tray(path.join(__dirname, 'hearth-tray@2x.png'));

  resetTray = function () {
    let tpl = trayApps.map(app => {
      return {
        label: app.data.attributes.name,
        type: 'normal',
        click: () => {
          window.webContents.send('open-project', app.data.id);
          window.show();
        }
      };
    }).concat([
      {type: 'separator'},
      {label: 'Exit Hearth', type: 'normal', click: () => app.quit()}
    ]);

    tray.setToolTip(`Ember Hearth v${app.getVersion()}`);
    tray.setContextMenu(Menu.buildFromTemplate(tpl));
  };

  resetTray();
}

function emitProjects(ev) {
  return db.apps.findAsync({})
    .filter(project => isEmberProject(project.data.attributes.path).catch(() => false))
    .map(addMetadata)
    .then(apps => {
      trayApps = apps;
      // send jsonapi list of apps
      ev.sender.send('project-list', {
        data: apps.map(project => project.data)
      });
    }).finally(() => resetTray());
}

function removeProject(ev, project) {
  project.data.commands.forEach(command => {
    killCmd(ev, command);
  });

  return db.apps.removeAsync({'data.id': project.data.id}).then(data => {
    return emitProjects(ev)
      .then(() => data);
  });
}

function updateProject(ev, project) {
  // if we ever need it, we can update the database here
  // update cli file
  const cli = project.data.attributes.cli;
  const cliPath = path.resolve(project.data.attributes.path, '.ember-cli');

  return fs.writeFileAsync(cliPath, JSON.stringify(cli, null, ' ')).then(() => {
    return emitProjects(ev);
  });
}

function addProject(ev, appPath) {
  let searchApp = db.apps.findOneAsync({"data.attributes.path": appPath});

  return isEmberProject(appPath)
    .then(() => searchApp)
    .then(appFound => {
      if (appFound) {
        ev.sender.send('open-project', appFound.data.id);
      } else {
        return db.apps.insertAsync({
          data: {
            id: uuid.v4(),
            type: 'project',
            attributes: {
              path: appPath,
              name: path.basename(appPath)
            }
          }
        }).then((data) => {
          return emitProjects(ev)
            .then(() => data);
        });
      }
    }).catch(() => {
      ev.sender.send('project-not-ember-app', appPath);
    });
}

function initProject(ev, data) {
  var ember = term.spawn(pathToBinary('ember'), ['init'], {
    cwd: path.normalize(data.path)
  });
  ember.stdout.on('data', (data) => {
    ev.sender.send('project-init-stdout', data.toString('utf8'));
    console.log(`${data.path} stdout: ${data.toString('utf8')}`);
  });
  ember.stderr.on('data', (data) => {
    ev.sender.send('project-init-stderr', data.toString('utf8'));
    console.log(`${data.path} stderr: ${data.toString('utf8')}`);
  });
  ember.on('close', (code) => {
    console.log(`${data.path} child process exited with code ${code}`);
    addProject(ev, data.path).then((project) => {
      ev.sender.send('project-init-end', project);
    });
  });
  ev.sender.send('project-init-start', data);
}

function runCmd(ev, cmd) {
  const cmdData = cmd.data;
  return db.apps.findAsync({'data.id': cmdData.relationships.project.data.id}).then((projects) => {
    let project = projects[0],
      args = [cmdData.attributes.name].concat(cmdData.attributes.args),
      cmdPromise;

    if (cmdData.attributes.options) {
      Object.keys(cmdData.attributes.options).forEach(optionName =>
        args.push(`--${optionName}`, cmdData.attributes.options[optionName]));
    }

    if (cmdData.attributes['in-term']) {
      cmdPromise = term.launchTermCommand(pathToBinary(cmdData.attributes.bin), args, {
        cwd: path.normalize(project.data.attributes.path)
      });
    } else {
      cmdPromise = Promise.resolve(term.spawn(pathToBinary(cmdData.attributes.bin), args, {
        cwd: path.normalize(project.data.attributes.path)
      }));
    }

    return cmdPromise.then((cmd) => {
      cmd.stdout.on('data', (data) => {
        ev.sender.send('cmd-stdout', cmdData, data.toString('utf8'));
        console.log(`cmd ${args} stdout: ${data}`);
      });
      cmd.stderr.on('data', (data) => {
        ev.sender.send('cmd-stderr', cmdData, data.toString('utf8'));
        console.log(`cmd ${args} stderr: ${data}`);
      });
      cmd.on('close', (code) => {
        delete processes[cmdData.id];
        ev.sender.send('cmd-close', cmdData, code);
        console.log(`cmd ${args} child process exited with code ${code}`);
      });
      ev.sender.send('cmd-start', cmdData);
      processes[cmdData.id] = cmd;
    });
  });
}

function killCmd(ev, cmd) {
  if (processes[cmd.data.id]) {
    processes[cmd.data.id].kill();
  }
}

function killAllProcesses() {
  Object.keys(processes).forEach(processId =>
    processes[processId].kill());
}

module.exports = {
  ready,

  runCmd,
  killCmd,

  emitProjects,
  initProject,
  addProject,
  updateProject,
  removeProject,

  killAllProcesses
};
