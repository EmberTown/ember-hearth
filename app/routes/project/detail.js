import Ember from 'ember';

const {run, inject, RSVP} = Ember;
const POLL_TIMEOUT = 2.5 * 1000;

export default Ember.Route.extend({
  store: inject.service(),
  commander: inject.service(),

  _readyPoll: undefined,

  pollHasProjects(resolve){
    if (this.controllerFor('application').get('ready')) {
      resolve();
    } else {
      this.set('_readyPoll', run.later(this, this.pollHasProjects, resolve, POLL_TIMEOUT));
    }
  },

  waitForProjects(){
    return new RSVP.Promise((resolve) =>
      this.pollHasProjects(resolve));
  },

  model({project_id}){
    return this.waitForProjects().then(() =>
      this.store.peekRecord('project', project_id));
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
  },

  deactivate(){
    if (this.get('_readyPoll')) {
      run.cancel(this.get('_readyPoll'));
    }
    this._super(...arguments);
  }
});
