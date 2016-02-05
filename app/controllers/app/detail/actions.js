import Ember from 'ember';

const {computed} = Ember;

export default Ember.Controller.extend({
  availableCommands: computed('model.help.commands', function () {
    const model = this.get('model'),
      isAddon = model.get('isAddon'),
      filterCommands = isAddon ?
        ['addon', 'help', 'init', 'new', 'serve', 'version'] :
        ['addon', 'help', 'init', 'new', 'serve', 'version'];

    return this.get('model.help.commands').filter(cmd => {
      return cmd.works === 'insideProject' && filterCommands.indexOf(cmd.name) === -1;
    });
  })
});
