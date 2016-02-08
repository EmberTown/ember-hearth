import Ember from 'ember';

const {inject} = Ember;

export default Ember.Route.extend({
  ipc: inject.service(),
  store: inject.service(),

  model({project_id}){
    return this.transitionTo('application');
  },
  afterModel(model){
    let store = this.get('store');
    const command = store.createRecord('command', {
      id: uuid.v4(),
      name: 'help',
      args: ['--json'],

      project: model
    });

    this.get('ipc').trigger('hearth-run-cmd', store.serialize(command, {includeId: true}));
  }
});
