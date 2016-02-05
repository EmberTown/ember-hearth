import Ember from 'ember';

const {computed} = Ember;

export default Ember.Component.extend({
  classNames: ['ui', 'vertical', 'segment'],

  selectedBlueprintName: '',
  selectedBlueprint: computed('selectedBlueprintName', function(){
    let selected = this.get('selectedBlueprintName');
    return this.get('blueprintOptions').filter(opt => selected === opt.name)[0];
  }),

  blueprintOptions: computed('cmd.availableBlueprints', function(){
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
  })
});
