import Ember from 'ember';

const {inject} = Ember;

function isRunning(stdout) {
  return stdout.indexOf('Serving on') !== -1;
}

export default Ember.Controller.extend({
  ipc: inject.service(),
  electron: inject.service(),

  model: [],

  init(){
    this._super(...arguments);

    let store = this.get('store');

    this.get('ipc').on('project-list', (ev, data) => {
      this.get('store').pushPayload('project', data);
    });

    this.get('ipc').on('cmd-start', (ev, cmd) => {
      this.get('store').peekRecord('command', cmd.id)
        .set('running', true);
    });
    this.get('ipc').on('cmd-stdout', (ev, cmd, data) => {
      this.get('store').peekRecord('command', cmd.id)
        .get('stdout').pushObject(data);
    });
    this.get('ipc').on('cmd-stderr', (ev, cmd, data) => {
      this.get('store').peekRecord('command', cmd.id)
        .get('stderr').pushObject(data);
    });

    this.get('ipc').on('cmd-close', (ev, cmd, code) => {
      let command = this.get('store').peekRecord('command', cmd.id);
      command.set('running', false);
      if (code === 0) {
        command.set('succeeded', true);
      } else {
        command.set('failed', true);
      }
    });

    this.get('ipc').trigger('hearth-ready');
  },

  actions: {
    addProject(){
      let dialog = this.get('electron.remote.dialog'),
        dirs = dialog.showOpenDialog({properties: ['openDirectory']});

      if (dirs.length) {
        this.get('ipc').trigger('hearth-add-project', dirs[0]);
      }
    }
  }
});
