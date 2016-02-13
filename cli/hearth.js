'use strict';

const Datastore = require('nedb');
const electron = require('electron');
const uuid = require('node-uuid');
const Promise = require('bluebird');
const jsonminify = require("jsonminify");
const spawn = require('child_process').spawn;
const fs = Promise.promisifyAll(require('fs'));
const path = require('path');
const dialog = require('dialog');

let processes = {},
  resetTray,
  db = {
    apps: Promise.promisifyAll(new Datastore({filename: path.resolve(__dirname, '..', 'hearth.nedb.json'), autoload: true}))
  },
  binaries = {
    ember: path.join(__dirname, '..', 'node_modules', 'ember-cli', 'bin', 'ember'),
    npm: path.join(__dirname, '..', 'node_modules', 'npm', 'bin', 'npm-cli.js')
  };

function pathToBinary(bin) {
  return binaries[bin];
}

function addMetadata(project) {
  // get some app metadata (could probably be cached, but avoids old entries if stored in db on add)
  console.log('stat', path.resolve(project.data.attributes.path, 'package.json'));
  const packagePath = path.resolve(project.data.attributes.path, 'package.json');
  const cliPath = path.resolve(project.data.attributes.path, '.ember-cli');

  return Promise.props({
    'package': fs.statAsync(packagePath),
    'cli': fs.statAsync(cliPath)
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

      return project;
    });
  });
}

var trayApps = [];

function ready(app, window) {
  const Tray = electron.Tray;
  const Menu = electron.Menu;
  let tray = new Tray(path.join(__dirname, 'hearth-tray.png'));
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
  return db.apps.findAsync({}).then((projects) => {
    return Promise.all(projects.map(doc => addMetadata(doc)))
      .then((apps) => {
        trayApps = apps;
        // send jsonapi list of apps
        ev.sender.send('project-list', {
          data: apps.map(project => project.data)
        });
      }).catch(e => console.error(e))
      .finally(() => resetTray());
  });
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

function addProject(ev, appPath) {
  console.log(db.apps);
  let searchApp = db.apps.findOneAsync({ "data.attributes.path": appPath });

  searchApp.then((appFound) => {
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
  });
}

function initProject(ev, data) {
  var ember = spawn(pathToBinary('ember'), ['init'], {
    cwd: path.normalize(data.path),
    detached: true
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
      args = [cmdData.attributes.name].concat(cmdData.attributes.args);

    if (cmdData.attributes.options) {
      Object.keys(cmdData.attributes.options).forEach(optionName =>
        args.push(`--${optionName}`, cmdData.attributes.options[optionName]));
    }

    var cmd = spawn(pathToBinary(cmdData.attributes.bin), args, {
      cwd: path.normalize(project.data.attributes.path),
      detached: true
    });
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
  initProject,
  runCmd,
  killCmd,
  emitProjects,
  addProject,
  removeProject,
  killAllProcesses
};
