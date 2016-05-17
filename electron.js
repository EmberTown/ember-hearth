/* jshint node: true */
'use strict';

const electron = require('electron');
const path = require('path');
const {app, BrowserWindow, ipcMain} = electron;
const dirname = __dirname || path.resolve(path.dirname());
const emberAppLocation = `file://${dirname}/dist/index.html`;
const hearth = require('./cli/hearth');

let mainWindow = null;

// Uncomment the lines below to enable Electron's crash reporter
// For more information, see http://electron.atom.io/docs/api/crash-reporter/

// electron.crashReporter.start({
//     productName: 'YourName',
//     companyName: 'YourCompany',
//     submitURL: 'https://your-domain.com/url-to-submit',
//     autoSubmit: true
// });

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

  mainWindow.webContents.on('crashed', () => {
    console.log('Your Ember app (or other code) in the main window has crashed.');
    console.log('This is a serious issue that needs to be handled and/or debugged.');
  });

  mainWindow.on('unresponsive', () => {
    console.log('Your Ember app (or other code) has made the window unresponsive.');
  });

  mainWindow.on('responsive', () => {
    console.log('The main window has become responsive again.');
  });

  mainWindow.on('closed', () => {
    hearth.killAllProcesses();
    mainWindow = null;
  });

  // Handle an unhandled error in the main thread
  //
  // Note that 'uncaughtException' is a crude mechanism for exception handling intended to
  // be used only as a last resort. The event should not be used as an equivalent to
  // "On Error Resume Next". Unhandled exceptions inherently mean that an application is in
  // an undefined state. Attempting to resume application code without properly recovering
  // from the exception can cause additional unforeseen and unpredictable issues.
  //
  // Attempting to resume normally after an uncaught exception can be similar to pulling out
  // of the power cord when upgrading a computer -- nine out of ten times nothing happens -
  // but the 10th time, the system becomes corrupted.
  //
  // The correct use of 'uncaughtException' is to perform synchronous cleanup of allocated
  // resources (e.g. file descriptors, handles, etc) before shutting down the process. It is
  // not safe to resume normal operation after 'uncaughtException'.
  process.on('uncaughtException', (err) => {
    console.log('An exception in the main thread was not handled.');
    console.log('This is a serious issue that needs to be handled and/or debugged.');
    console.log(`Exception: ${err}`);
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
  ipcMain.on(evName, (ev, data) => {
    console.log('ipc', evName, ...data);
    hearth[mapping[evName]](ev, ...data);
  });
});
