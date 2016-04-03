import Ember from 'ember';

const {computed} = Ember;

export default Ember.Controller.extend({

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
  })
});
