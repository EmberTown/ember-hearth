/* jshint undef: false */

const {BrowserWindow, app} = require('electron');

let mainWindow = null;

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

    if (process.env.EMBER_ENV === 'test') {
        mainWindow.loadURL('file://' + __dirname + '/index.html');
    } else {
        mainWindow.loadURL('file://' + __dirname + '/dist/index.html');
    }

    mainWindow.on('closed', function onClosed() {
        mainWindow = null;
    });
});

/* jshint undef: true */
