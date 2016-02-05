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

    this.get('ipc').on('app-list', (ev, data) => {
      this.get('store').pushPayload('project', data);
    });

    this.get('ipc').on('app-start', (ev, data) => {
      let project = this.get('store').peekRecord('project', data.id);
      project.set('starting', true);
    });
    this.get('ipc').on('app-close', (ev, data) => {
      let project = this.get('store').peekRecord('project', data.id);
      project.set('starting', false);
      project.set('running', false);
    });
    this.get('ipc').on('app-help', (ev, app, help) => {
      let project = this.get('store').peekRecord('project', app.id);
      if (project) {
        project.set('help', help);
      }
    });

    this.get('ipc').on('app-stdout', (ev, app, data) => {
      if (app.id) {
        let project = this.store.peekRecord('project', app.id);
        if (project) {
          if (project.get('starting') && !project.get('running') && isRunning(data)) {
            project.set('running', true);
          }
          project.get('stdout').pushObject(data);
          project.set('lastStdout', data);
        }
      }
    });
    this.get('ipc').on('app-stderr', (ev, app, data) => {
      if (app.id) {
        let project = this.store.peekRecord('project', app.id);
        if (project) {
          project.get('stderr').pushObject(data);
        }
      }
    });

    this.get('ipc').trigger('hearth-ready');
  },

  actions: {
    addApp(){
      let dialog = this.get('electron.remote.dialog'),
        dirs = dialog.showOpenDialog({properties: ['openDirectory']});

      if (dirs.length) {
        this.get('ipc').trigger('hearth-add-app', dirs[0]);
      }
    }
  }
});
