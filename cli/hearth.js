'use strict';

var Datastore = require('nedb'),
  uuid = require('node-uuid'),
  Promise = require('bluebird'),
  jsonminify = require("jsonminify"),
  spawn = require('child_process').spawn,
  fs = Promise.promisifyAll(require('fs')),
  path = require('path');

const EMBER_BIN = path.join(__dirname, '..', 'node_modules', 'ember-cli', 'bin', 'ember');

let processes = {},
  db = {
    apps: Promise.promisifyAll(new Datastore({filename: path.resolve(__dirname, 'hearth.nedb.json'), autoload: true}))
  };

function addMetadata(app) {
  // get some app metadata (could probably be cached, but avoids old entries if stored in db on add)
  console.log('stat', path.resolve(app.data.attributes.path, 'package.json'));
  const packagePath = path.resolve(app.data.attributes.path, 'package.json');
  const cliPath = path.resolve(app.data.attributes.path, '.ember-cli');

  return Promise.props({
    'package': fs.statAsync(packagePath),
    'cli': fs.statAsync(cliPath)
  }).then((stats) => {
    return Promise.props({
      'package': stats.package.isFile() && fs.readFileAsync(packagePath),
      cli: stats.cli.isFile() && fs.readFileAsync(cliPath)
    }).then(data => {
      if (data.package) app.data.attributes.package = JSON.parse(data.package);
      if (data.cli) app.data.attributes.cli = JSON.parse(jsonminify(data.cli.toString('utf8')));

      // TODO: read default ports
      if (!app.data.attributes.cli) app.data.attributes.cli = {};
      if (!app.data.attributes.cli.testPort) app.data.attributes.cli.testPort = 7357;
      if (!app.data.attributes.cli.port) app.data.attributes.cli.port = 4200;

      return app;
    });
  });
}

function emitApps(ev) {
  return db.apps.findAsync({}).then((apps) => {
    return Promise.all(apps.map(doc => addMetadata(doc)))
      .then((apps) => {
        // send jsonapi list of apps
        ev.sender.send('app-list', {
          data: apps.map(app => app.data)
        });
      }).catch(e => console.error(e));
  });
}

function addApp(ev, appPath) {
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
    return emitApps(ev)
      .then(() => data);
  });
}

function initApp(ev, data) {
  var ember = spawn(EMBER_BIN, ['init'], {
    cwd: path.normalize(data.path),
    detached: true
  });
  ember.stdout.on('data', (data) => {
    ev.sender.send('app-init-stdout', data.toString('utf8'));
    console.log(`${data.path} stdout: ${data.toString('utf8')}`);
  });
  ember.stderr.on('data', (data) => {
    ev.sender.send('app-init-stderr', data.toString('utf8'));
    console.log(`${data.path} stderr: ${data.toString('utf8')}`);
  });
  ember.on('close', (code) => {
    console.log(`${data.path} child process exited with code ${code}`);
    addApp(ev, data.path).then((app) => {
      ev.sender.send('app-init-end', app);
    });
  });
  ev.sender.send('app-init-start', data);
}

function runCmd(ev, cmd) {
  const cmdData = cmd.data;
  return db.apps.findAsync({'data.id': cmdData.relationships.project.data.id}).then((apps) => {
    let app = apps[0],
      args = [cmdData.attributes.name].concat(cmdData.attributes.args);

    if (cmdData.attributes.options) {
      Object.keys(cmdData.attributes.options).forEach(optionName =>
        args.push(`--${optionName}`, cmdData.attributes.options[optionName]));
    }

    console.log('spawning', path.normalize(app.data.attributes.path), EMBER_BIN, args);
    var ember = spawn(EMBER_BIN, args, {
      cwd: path.normalize(app.data.attributes.path),
      detached: true
    });
    ember.stdout.on('data', (data) => {
      ev.sender.send('cmd-stdout', cmdData, data.toString('utf8'));
      console.log(`cmd ${args} stdout: ${data}`);
    });
    ember.stderr.on('data', (data) => {
      ev.sender.send('cmd-stderr', cmdData, data.toString('utf8'));
      console.log(`cmd ${args} stderr: ${data}`);
    });
    ember.on('close', (code) => {
      ev.sender.send('cmd-close', cmdData, code);
      console.log(`cmd ${args} child process exited with code ${code}`);
    });
    ev.sender.send('cmd-start', cmdData);
    processes[cmdData.id] = ember;
  });
}

function killCmd(ev, cmd) {
  processes[cmd.data.id].kill();
  ev.sender.send('cmd-kill', cmd.data);
}

function killAllProcesses(){
  Object.keys(processes).forEach(processId =>
    processes[processId].kill());
}

module.exports = {
  initApp,
  runCmd,
  killCmd,
  emitApps,
  addApp,
  killAllProcesses
};
