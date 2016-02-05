import DS from 'ember-data';

const {attr, belongsTo} = DS;

export default DS.Model.extend({
  name: attr('string'),
  args: attr(),
  options: attr(),

  project: belongsTo('project')
});
