import Ember from 'ember';

const {computed} = Ember;

export default Ember.Controller.extend({

  helpCommand: computed('model.commands.[]', function () {
    return this.get('model.commands')
      .filter(cmd => cmd.get('name') === 'help' && cmd.get('args.length') && cmd.get('args')[0] === '--json')
      .get('firstObject');
  }),

  help: computed('helpCommand.stdout.length', function () {
    let helpCommand = this.get('helpCommand');
    if (helpCommand) {
      if (helpCommand.get('stdout.length') >= 2) {
        try {
          return JSON.parse(helpCommand.get('stdout').slice(1).join(''));
        } catch (e) {
          console.error('error parsing help command json', helpCommand.get('stdout'));
        }
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
  })
});
