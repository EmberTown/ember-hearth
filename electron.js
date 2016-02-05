/* jshint node: true */
'use strict';

var electron = require('electron'),
  hearth  = require('./cli/hearth');

var app = electron.app;
var ipc = electron.ipcMain;
var mainWindow = null;
var BrowserWindow = electron.BrowserWindow;

electron.crashReporter.start();

app.on('window-all-closed', function onWindowAllClosed() {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('ready', function onReady() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600
  });

  delete mainWindow.module;

  // If you want to open up dev tools programmatically, call
  // mainWindow.openDevTools();

  // By default, we'll open the Ember App by directly going to the
  // file system.
  //
  // Please ensure that you have set the locationType option in the
  // config/environment.js file to 'hash'. For more information,
  // please consult the ember-electron readme.
  mainWindow.loadURL('file://' + __dirname + '/dist/index.html');

  mainWindow.on('closed', function onClosed() {
    hearth.stopAllApps();
    mainWindow = null;
  });
});

var mapping = {
  'hearth-add-app': 'addApp',
  'hearth-ready': 'emitApps',
  'hearth-start-app': 'startApp',
  'hearth-stop-app': 'stopApp',
  'hearth-init-app': 'initApp',
  'hearth-app-help': 'emitEmberHelp'
};

Object.keys(mapping).forEach((evName) => {
  ipc.on(evName, (ev, data) => {
    console.log('ipc', evName, ...data);
    hearth[mapping[evName]](ev, ...data);
  });
});
