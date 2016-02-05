import Ember from 'ember';

const {computed, inject} = Ember;

function flatten(array) {
  return [].concat.apply([], array);
}


export default Ember.Component.extend({
  classNames: ['ui', 'vertical', 'segment'],

  ipc: inject.service(),
  store: inject.service(),

  createdCommand: undefined,

  anonymousFields: [],

  selectedBlueprintName: '',
  selectedBlueprint: computed('selectedBlueprintName', function () {
    let selected = this.get('selectedBlueprintName');
    return this.get('blueprintOptions').filter(opt => selected === opt.name)[0];
  }),

  blueprintOptions: computed('cmd.availableBlueprints', function () {
    let options = [],
      blueprints = this.get('cmd.availableBlueprints');

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
    updateAnonymousField(idx, ev){
      this.get('anonymousFields')[idx] = ev.target.value;
    },
    runCmd(){
      let store = this.get('store'),
        blueprint = this.get('selectedBlueprint'),
        app = this.get('app'),
        anonymousFields = this.get('anonymousFields');

      const command = store.createRecord('command', {
        id: uuid.v4(),
        name: this.get('cmd.name'),
        args: flatten((blueprint ? [blueprint.name] : [])
          .concat(anonymousFields).map(arg => arg.split(' '))),

        project: app
      });

      this.set('createdCommand', command);

      this.get('ipc').trigger('hearth-run-cmd', store.serialize(command, {includeId: true}));
    }
  }
});
