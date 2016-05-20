'use strict';

const spawn = require('child_process').spawn;
const argv  = require('optimist').argv;

function runElectron(electronPath, testsPath) {
  const electron = spawn(electronPath, [testsPath]);
  let hasErrors = false;

  electron.stderr.on('data', (data) => {
    console.log('stderr.data', data, data.toString('utf8'));
  });

  electron.on('close', (code) => {
    console.log('child process exited with code', code);
  });


  // Cleanup Electron output to be TAP (test anything protocol) compliant
  electron.stdout.on('data', function (data) {
    console.log(data.toString('utf8'));
    data = data.toString('utf8');

    if (data.indexOf('[qunit-logger]') > -1) {
      data = data.replace('[qunit-logger] ', '');
      data = data + '\n';

      process.stdout.write(data);

      if (data === '# done with errors') {
        hasErrors = true;
      }

      if (data.indexOf('# done') > -1) {
        electron.kill();
        process.exit(hasErrors ? 1 : 0);
      }
    }
  });
}

runElectron(argv['electron-path'], argv['tests-path']);
