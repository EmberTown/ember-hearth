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

function serializeOne(data) {

}
function deserializeOne() {

}

function addMetadata(app) {
  console.log(app);
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

function emitEmberHelp(ev, app) {
  var ember = spawn(EMBER_BIN, ['--help', '--json'], {
    cwd: path.normalize(app.data.attributes.path),
    detached: true
  });
  let i = 0,
    data = '';

  ember.stdout.on('data', (stdoutData) => {
    // ignore ember version header
    if (i > 0) {
      data += stdoutData.toString('utf8');
    }
    i++;
    console.log(`${app.data.attributes.path} stdout: ${stdoutData.toString('utf8')}`);
  });
  ember.stderr.on('data', (data) => {
    console.log(`${app.data.attributes.path} stderr: ${data.toString('utf8')}`);
  });
  ember.on('close', (code) => {
    ev.sender.send('app-help', app, JSON.parse(data));
    console.log(`${app.data.attributes.path} child process exited with code ${code}`);
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

function startApp(ev, app) {
  var ember = spawn(EMBER_BIN, ['s'], {
    cwd: path.normalize(app.data.attributes.path),
    detached: true
  });
  ember.stdout.on('data', (data) => {
    ev.sender.send('app-stdout', app, data.toString('utf8'));
    console.log(`${app.data.attributes.name} stdout: ${data}`);
  });
  ember.stderr.on('data', (data) => {
    ev.sender.send('app-stderr', app, data.toString('utf8'));
    console.log(`${app.data.attributes.name} stderr: ${data}`);
  });
  ember.on('close', (code) => {
    ev.sender.send('app-close', app, code);
    console.log(`${app.data.attributes.name} child process exited with code ${code}`);
  });
  ev.sender.send('app-start', app);
  processes[app.data.id] = ember;
}

function stopApp(ev, app) {
  processes[app.data.id].kill();
}

function stopAllApps() {
  Object.keys(processes).forEach(appId =>
    processes[appId].kill());
}

function runCmd(ev, cmd) {
  const cmdData = cmd.data;
  return db.apps.findAsync({'data.id': cmdData.relationships.project.data.id}).then((apps) => {
    let app = apps[0],
      args = [cmdData.attributes.name].concat(cmdData.attributes.args);

    console.log('spawning', EMBER_BIN, args);
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
  });
}

module.exports = {
  initApp,
  runCmd,
  stopAllApps,
  stopApp,
  emitEmberHelp,
  emitApps,
  addApp,
  startApp
};
