import Ember from 'ember';

const {computed} = Ember;

export default Ember.Controller.extend({
  queryParams: ['addonsFilter'],

  addons: computed.alias('help.addons'),
  addonsFilter: [],

  requiresCliUpdate: computed('addons.@each.name', function(){
    return this.get('addons.length') && this.get('addons').every(addon => addon.name === 'help');
  }),

  filteredAddons: computed('addons.[]', 'addonsFilter.[]', function(){
    const filter = this.get('addonsFilter');
    const addons = this.get('addons');

    return addons.filter((addon) =>
      // return addons where addon name is not in filter
      filter.indexOf(addon.name) === -1);
  }),

  helpCommand: computed('model.commands.[]', function () {
    return this.get('model.commands')
      .filter(cmd => cmd.get('name') === 'help' && cmd.get('args.firstObject') === '--json')
      .get('lastObject');
  }),

  help: computed('helpCommand.stdout.length', function () {
    let helpCommand = this.get('helpCommand');

    if (helpCommand && helpCommand.get('stdout.length')) {
      try {
        const stdoutString = helpCommand.get('stdout').join('');
        return JSON.parse(stdoutString.substring(stdoutString.indexOf('{')));
      } catch (e) {
        console.error('error parsing help command json', helpCommand.get('stdout'));
      }
    }
  }),

  availableCommands: computed('help.commands', function () {
    if (this.get('help')) {
      const model = this.get('model'),
        isAddon = model.get('isAddon'),
        filterCommands = isAddon ?
          ['addon', 'help', 'init', 'new', 'serve', 'version'] :
          ['addon', 'help', 'init', 'new', 'serve', 'version'];

      return this.get('help.commands').filter(cmd => {
        return cmd.works === 'insideProject' && filterCommands.indexOf(cmd.name) === -1;
      });
    }
  }),

  actions: {
    toggleAddonFilter(addon) {
      const filter = this.get('addonsFilter');
      const idx = filter.indexOf(addon.name);

      if (idx !== -1) {
        filter.removeAt(idx);
      } else {
        filter.pushObject(addon.name);
      }
    }
  }
});
