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
    this.get('ipc').trigger('hearth-app-help',
      this.get('store').serialize(model, {includeId: true}));
  }
});
