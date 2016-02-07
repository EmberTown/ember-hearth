import Ember from 'ember';

const {inject} = Ember;

export default Ember.Route.extend({
  ipc: inject.service(),
  store: inject.service(),

  model({app_id}){
    return this.transitionTo('application');
    //return this.get('store').peekRecord('project', app_id);
  },
  afterModel(model){
    let store = this.get('store');
    const command = store.createRecord('command', {
      id: uuid.v4(),
      name: 'help',
      args: ['--json'],

      project: model
    });

    this.set('startCommand', command);
    this.get('ipc').trigger('hearth-run-cmd', store.serialize(command, {includeId: true}));

    //this.get('ipc').trigger('hearth-app-help',
    //  this.get('store').serialize(model, {includeId: true}));
  }
});
