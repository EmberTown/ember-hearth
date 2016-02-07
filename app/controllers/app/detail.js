import Ember from 'ember';

const {inject} = Ember;

export default Ember.Controller.extend({
  ipc: inject.service(),
  store: inject.service(),

  actions: {
    startServer(){
      let store = this.get('store');
      const command = store.createRecord('command', {
        id: uuid.v4(),
        name: 's',
        args: [],

        project: this.get('model')
      });

      this.get('ipc').trigger('hearth-run-cmd', store.serialize(command, {includeId: true}));
    },
    stopServer(){
      this.get('ipc').trigger('hearth-kill-cmd', this.get('store').serialize(this.get('model.serveCommand'), {includeId: true}));
    }
  }
});
