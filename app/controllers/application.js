import Ember from 'ember';

const {inject} = Ember;

export default Ember.Controller.extend({
  ipc: inject.service(),
  electron: inject.service(),

  ready: false,
  model: [],

  init(){
    this._super(...arguments);

    let store = this.get('store');

    this.get('ipc').on('project-list', (ev, data) => {
      // create lookup table for current project list
      let projects = data.data.reduce((all, project) => {
        all[project.id] = true;
        return all;
      }, {});

      this.get('store').pushPayload('project', data);
      // unload all records that aren't in project list
      this.get('store').peekAll('project')
        .filter(project => !projects[project.get('id')])
        .forEach(project => store.unloadRecord(project));
      
      this.set('ready', true);
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
    this.get('ipc').on('open-project', (ev, projectId) => {
      this.transitionToRoute('project.detail', this.get('store').peekRecord('project', projectId));
    });

    this.get('ipc').on('project-not-ember-app', (ev, path) => {
      alert(`Project at "${path}" is not an ember app`);
    });

    this.get('ipc').on('cmd-close', (ev, cmd, code) => {
      let command = this.get('store').peekRecord('command', cmd.id);
      command.set('running', false);
      if (code === 0) {
        command.set('succeeded', true);
        command.onSucceed();
      } else {
        command.set('failed', true);
        command.onFail();
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
