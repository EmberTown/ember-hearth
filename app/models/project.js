import DS from 'ember-data';
import Ember from 'ember';

const {attr} = DS;
const {computed} = Ember;

export default DS.Model.extend({
  name: attr('string'),
  path: attr('string'),
  cli: attr(),

  stdout: [],
  stderr: [],

  'package': attr(),
  isAddon: computed('package.keywords', function(){
    const keywords = this.get('package.keywords');
    return keywords ? keywords.indexOf('ember-addon') !== -1 : false;
  })
});
