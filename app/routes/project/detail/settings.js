import Ember from 'ember';

export default Ember.Route.extend({
  model(){
    return this.modelFor('project.detail');
  },
  setupController(ctrl, model){
    ctrl.set('model', model);
    ctrl.reset();
  }
});
