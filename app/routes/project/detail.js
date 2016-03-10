import Ember from 'ember';

const {inject} = Ember;

export default Ember.Route.extend({
  store: inject.service(),
  commander: inject.service(),

  model(){
    return this.transitionTo('application');
  },
  afterModel(model){
    let store = this.get('store');
    this.get('commander').start(store.createRecord('command', {
      bin: 'ember',
      id: uuid.v4(),
      name: 'help',
      args: ['--json'],

      project: model
    }));
  }
});
