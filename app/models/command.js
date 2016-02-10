import DS from 'ember-data';

const {attr, belongsTo} = DS;

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

  init(){
    this._super(...arguments);
    this.set('stdout', []);
    this.set('stderr', []);
  }
});
