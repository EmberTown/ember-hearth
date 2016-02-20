import Ember from 'ember';

const {computed, inject, run} = Ember;

export default Ember.Controller.extend({
  ipc: inject.service(),
  commander: inject.service(),
  ajax: inject.service(),
  project: inject.controller('project.detail'),

  filterQuery: '',
  filteredAddons: computed('filterQuery', 'model.addons', function(){
    const query = this.get('filterQuery');
    return this.get('model.addons').filter(addon => addon.name.indexOf(query) !== -1);
  }),

  triggerProjectReload(ev, cmd){
    let command = this.get('store').peekRecord('command', cmd.id);
    if (command.get('succeeded') &&
      ['install', 'uninstall'].indexOf(command.get('name')) !== -1 &&
      command.get('bin') === 'ember') {
      this.get('ipc').trigger('hearth-ready');
    }
  },

  init(){
    this._super(...arguments);
    this.get('ipc').on('cmd-close', this, this.triggerProjectReload);
  },

  destroy(){
    this.get('ipc').on('cmd-close', this, this.triggerProjectReload);
    this._super(...arguments);
  },

  actions: {
    install(addon) {
      const store = this.get('store'),
        commander = this.get('commander');

      let command = store.createRecord('command', {
        id: uuid.v4(),
        bin: 'ember',
        name: 'install',
        args: [addon.name],
        project: this.get('project.model'),
        inTerm: true,
        onSucceed(){
          let servingCommand = this.get('project.commands')
            .filter(c => c.get('bin') === 'ember' && c.get('name') === 'install')
            .get('lastObject');

          if (servingCommand && servingCommand.get('running')) {
            commander.restart(servingCommand);
          }
        }
      });

      Ember.set(addon, 'command', command);
      commander.start(command);
    }
  }
})
;
