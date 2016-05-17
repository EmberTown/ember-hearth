import Ember from 'ember';

const {computed, inject} = Ember;

function flatten(array) {
  return [].concat.apply([], array);
}

export default Ember.Component.extend({
  classNames: ['ui segment'],

  commander: inject.service(),
  store: inject.service(),

  extended: false,

  anonymousFields: [],
  options: {},

  init(){
    this._super(...arguments);
    this.set('options', {});
    this.set('anonymousFields', []);
  },

  didInsertElement(){
    this._super(...arguments);
    if (!this.get('createdCommand')) {
      // restore last command if exists
      const commands = this.get('project.commands');
      const command = this.get('cmd');

      const createdCommand = commands
        .filter(c => c.get('name') === command.name)
        .get('lastObject');

      if (createdCommand) {
        this.set('createdCommand', createdCommand);
      }
    }
  },

  selectedBlueprintName: '',
  selectedBlueprint: computed('selectedBlueprintName', function () {
    let selected = this.get('selectedBlueprintName');
    return this.get('blueprintOptions').filter(opt => selected === opt.name)[0];
  }),

  blueprintOptions: computed('cmd.availableBlueprints', function () {
    let options = [];
    const blueprints = this.get('cmd.availableBlueprints');

    if (blueprints) {
      this.get('cmd.availableBlueprints').forEach(blueprint => {
        Object.keys(blueprint).forEach(blueprintName => {
          blueprint[blueprintName].forEach(option => {
            options.push(option);
          });
        });
      });
    }

    return options;
  }),

  actions: {
    toggleExtend(){
      // maybe use ember-composable-helpers instead
      this.toggleProperty('extended');
    },
    updateOption(name, ev){
      this.set(`options.${name}`, ev.target.value);
    },
    updateAnonymousField(idx, ev){
      this.get('anonymousFields')[idx] = ev.target.value;
    },
    runCmd(){
      const store = this.get('store');
      const blueprint = this.get('selectedBlueprint');
      const project = this.get('project');
      const anonymousFields = this.get('anonymousFields');

      const command = store.createRecord('command', {
        bin: 'ember',
        id: uuid.v4(),
        name: this.get('cmd.name'),
        options: this.get('options'),
        args: flatten((blueprint ? [blueprint.name] : [])
          .concat(anonymousFields).map(arg => arg.split(' '))),
        project: project
      });

      this.set('createdCommand', command);
      this.get('commander').start(command);
    }
  }
});
