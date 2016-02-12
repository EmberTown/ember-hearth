import Ember from 'ember';

const {inject, run} = Ember;

export default Ember.Controller.extend({
  ipc: inject.service(),
  commander: inject.service(),
  ajax: inject.service(),
  project: inject.controller('project.detail'),

  searchResults: [],

  triggerProjectReload(ev, cmd){
    let command = this.get('store').peekRecord('command', cmd.id);
    if (command.get('succeeded') &&
      ['install', 'uninstall'].indexOf(command.get('name')) !== -1 &&
      command.get('bin') === 'npm') {
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

  updateSearchResult(query){
    let commands = this.get('project.model.commands');

    this.get('ajax').request(`http://npmsearch.com/query?q=${encodeURIComponent(`"${query}"`)}&fields=name,version,homepage,rating&sort=rating:desc`).then(result => {
      this.set('searchResults', result.results.map(pkg => {
        return {
          name: pkg.name[0],
          version: pkg.version[0],
          homepage: pkg.homepage[0],
          rating: pkg.rating[0],
          command: commands.filter(c => c.get('name') === 'install' && c.get('bin') === 'npm' && c.get('args')[0] === pkg.name[0])
            .get('firstObject')
        };
      }));
    });
  },

  actions: {
    updateSearchResult(ev) {
      run.debounce(this, this.updateSearchResult, ev.target.value, 200);
    },

    uninstall(pkg) {
      const store = this.get('store'),
        commander = this.get('commander');

      let command = store.createRecord('command', {
        id: uuid.v4(),
        bin: 'npm',
        name: 'uninstall',
        args: [pkg.name, '--save-dev'],
        project: this.get('project.model'),
        onSucceed(){
          let servingCommand = this.get('project.commands')
            .filter(c => c.get('bin') === 'ember' && c.get('name') === 's')
            .get('lastObject');

          if (servingCommand && servingCommand.get('running')) {
            commander.restart(servingCommand);
          }
        }
      });

      Ember.set(pkg, 'command', command);
      commander.start(command);
    },

    install(pkg) {
      const store = this.get('store'),
        commander = this.get('commander');

      let command = store.createRecord('command', {
        id: uuid.v4(),
        bin: 'npm',
        name: 'install',
        args: [pkg.name, '--save-dev'],
        project: this.get('project.model'),
        onSucceed(){
          let servingCommand = this.get('project.commands')
            .filter(c => c.get('bin') === 'ember' && c.get('name') === 's')
            .get('lastObject');

          if (servingCommand && servingCommand.get('running')) {
            commander.restart(servingCommand);
          }
        }
      });

      Ember.set(pkg, 'command', command);
      commander.start(command);
    }
  }
})
;
