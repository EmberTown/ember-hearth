import DS from 'ember-data';
import Ember from 'ember';

const {attr, belongsTo} = DS;
const {K} = Ember;

export default DS.Model.extend({
  bin: attr('string'),
  name: attr('string'),
  args: attr(),
  options: attr(),

  project: belongsTo('project'),
  running: false,
  succeeded: false,
  failed: false,

  stdout: [],
  stderr: [],

  onSucceed: K,
  onFail: K,

  init(){
    this._super(...arguments);
    this.set('stdout', []);
    this.set('stderr', []);
  },

  reset(){
    this.setProperties({
      running: false,
      succeeded: false,
      failed: false,
      stdout: [],
      stderr: []
    });
  }
});
