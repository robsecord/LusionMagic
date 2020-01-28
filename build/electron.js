const { app, BrowserWindow } = require('electron');
const path = require('path');
const isDev = require('electron-is-dev');
const isProd = !isDev;

let win;

function createWindow () {
    app.commandLine.appendSwitch("autoplay-policy", "no-user-gesture-required");

    // Create the browser window.
    win = new BrowserWindow({
        width: 1480,
        height: 960,
        frame: false,
        title: 'Lusion Magic',
        darkTheme: true,
        backgroundColor: '#000000',
        fullscreen: isProd,
        alwaysOnTop: isProd,
        autoHideMenuBar: true,
        webPreferences: {
            devTools: isDev,
            nodeIntegration: true,
            // experimentalFeatures: true,
            // webviewTag: true,
        }
    });

    const url = isDev ? 'http://localhost:3000' : `file://${path.join(__dirname, '../build/index.html')}`;
    const qs = isDev ? '/?d=1' : '';
    win.loadURL(url + qs);

    win.webContents.openDevTools();

    win.once('ready-to-show', () => {
        win.show();
    });

    win.on('closed', () => {
        win = null
    });
}

app.on('ready', () => {
    createWindow();
});

app.on('window-all-closed', () => {
    if (isDev) {
        app.quit();
    } else {
        createWindow();
    }
});

app.on('activate', () => {
    if (win === null) {
        createWindow();
    }
});
