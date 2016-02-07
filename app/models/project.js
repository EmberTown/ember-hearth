import DS from 'ember-data';
import Ember from 'ember';

const {attr, hasMany} = DS;
const {computed} = Ember;

export default DS.Model.extend({
  name: attr('string'),
  path: attr('string'),
  cli: attr(),

  'package': attr(),
  commands: hasMany('command'),

  serveCommand: computed('commands.[]', function () {
    return this.get('commands')
      .filter(c => c.get('name') === 's')
      .get('lastObject');
  }),

  isServing: computed('serveCommand.running', 'serveCommand.stdout.length', function () {
    return this.get('serveCommand.running') && this.get('serveCommand.stdout')
        .some(stdout => stdout.indexOf('Serving on') !== -1);
  }),

  isAddon: computed('package.keywords', function () {
    const keywords = this.get('package.keywords');
    return keywords ? keywords.indexOf('ember-addon') !== -1 : false;
  })
});
