'use strict';

const emberElectron = require('ember-electron');
const electronTestTask = require('ember-electron/lib/commands/electron-test/task');

function spyFor(name, ctx) {
  return function spy(methodName) {
    let orig = ctx[methodName];
    ctx[methodName] = function () {
      console.log(name, ':', methodName);

      const result = orig.call(this, ...arguments);

      if (
        Array.isArray(result) ||
        typeof result === 'string' ||
        typeof result === 'number'
      ) {
        console.log('\t=', JSON.stringify(result));
      }
      return result;
    };
  };
}

const electronSpy = spyFor('ember-electron', emberElectron);
const electronCommandTestTaskSpy = spyFor('command-electron:test.Task', electronTestTask);

electronSpy('included');
electronSpy('includedCommands');
electronSpy('treeForVendor');
electronSpy('postprocessTree');
electronSpy('contentFor');

electronCommandTestTaskSpy('testemOptions');
electronCommandTestTaskSpy('electronCommand');
/*jshint node:true*/
module.exports = {
  name: 'ember-electron-spy',
  description: 'spy on ember-electron',

  included: emberElectron.included,
  treeForVendor: emberElectron.treeForVendor,
  postprocessTree: emberElectron.postprocessTree,
  contentFor: emberElectron.contentFor,

  includedCommands: function () {
    const commandElectron = require('ember-electron/lib/commands/electron');
    const commandElectronTest = require('ember-electron/lib/commands/electron-test');

    const electronCommandSpy = spyFor('electron-command', commandElectron);
    const electronCommandTestSpy = spyFor('command-electron:test', commandElectronTest);

    commandElectron.name = 'spy-electron';
    commandElectron.description = 'spied: ' + commandElectron.description;
    commandElectronTest.name = 'spy-electron:test';
    commandElectronTest.description = 'spied:' + commandElectronTest.description;

    electronCommandSpy('buildWatch');
    electronCommandSpy('runInspectorServer');
    electronCommandSpy('runElectron');
    electronCommandSpy('run');

    electronCommandTestSpy('init');
    electronCommandTestSpy('tmp');
    electronCommandTestSpy('rmTmp');
    electronCommandTestSpy('taskOptions');
    electronCommandTestSpy('runTestsForDev');
    electronCommandTestSpy('runTestsForCi');
    electronCommandTestSpy('getTestPageQueryString');
    electronCommandTestSpy('run');

    return {
      'spy-electron': commandElectron,
      'spy-electron:test': commandElectronTest
    };
  }
};
