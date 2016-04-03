/* jshint node: true */
'use strict';

const electron = require('electron');
const app = electron.app;
const ipc = electron.ipcMain;
const BrowserWindow = electron.BrowserWindow;
const emberAppLocation = `file://${__dirname}/dist/index.html`;
const path = require('path');
const hearth = require('./cli/hearth');

let mainWindow = null;

electron.crashReporter.start();

app.on('window-all-closed', function onWindowAllClosed() {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('ready', function onReady() {
  mainWindow = new BrowserWindow({
    icon: path.join(__dirname, 'cli', 'hearth-tray.png'),
    width: 800,
    height: 600
  });

  hearth.ready(app, mainWindow);

  delete mainWindow.module;

  // If you want to open up dev tools programmatically, call
  // mainWindow.openDevTools();

  // By default, we'll open the Ember App by directly going to the
  // file system.
  //
  // Please ensure that you have set the locationType option in the
  // config/environment.js file to 'hash'. For more information,
  // please consult the ember-electron readme.
  mainWindow.loadURL(emberAppLocation);

  // If a loading operation goes wrong, we'll send Electron back to
  // Ember App entry point
  mainWindow.webContents.on('did-fail-load', () => {
    mainWindow.loadURL(emberAppLocation);
  });

  mainWindow.on('closed', () => {
    hearth.killAllProcesses();
    mainWindow = null;
  });
});

var mapping = {
  'hearth-add-project': 'addProject',
  'hearth-update-project': 'updateProject',
  'hearth-remove-project': 'removeProject',
  'hearth-ready': 'emitProjects',
  'hearth-init-project': 'initProject',

  'hearth-run-cmd': 'runCmd',
  'hearth-kill-cmd': 'killCmd'
};

Object.keys(mapping).forEach((evName) => {
  ipc.on(evName, (ev, data) => {
    console.log('ipc', evName, ...data);
    hearth[mapping[evName]](ev, ...data);
  });
});
