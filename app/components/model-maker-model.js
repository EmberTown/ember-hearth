import Ember from 'ember';
import {attrToArg} from 'ember-hearth/utils/model-maker';

const {inject:{service}} = Ember;

export default Ember.Component.extend({
  commander: service(),
  store: service(),

  project: undefined,

  relationshipTransforms: ['belongsTo', 'hasMany'],

  actions: {
    reset(){
      this.set('model.name', '');
      this.get('model.attrs').clear();
      this.get('model.attrs').pushObject({name: '', transform: ''});
    },

    removeAttribute(idx) {
      this.get('model.attrs').removeAt(idx, 1);
    },

    addAttribute(){
      this.get('model.attrs').pushObject({name: '', transform: 'belongsTo', relationshipName: ''});
    },

    generateModel(model){
      const relationshipTransforms = this.get('relationshipTransforms');
      if (!(model.name && model.name.length)) {
        return alert('Model requires a name.');
      }
      if (!model.attrs.every(attr => attr.name.length &&
        (relationshipTransforms.indexOf(attr.transform) === -1 ||
        (attr.relationshipName && attr.relationshipName.length)))) {
        return alert('All attributes require a name and relationship name if transform requires it.');
      }

      const store = this.get('store');
      const project = this.get('project');
      const attrs = model.attrs.map(attrToArg);

      const command = store.createRecord('command', {
        bin: 'ember',
        id: uuid.v4(),
        name: 'g',
        inTerm: true,
        args: ['model', model.name].concat(attrs),
        project: project
      });

      this.set('generateCommand', command);
      this.get('commander').start(command);
    }
  }
});
