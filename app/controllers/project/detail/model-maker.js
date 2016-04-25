/* global require */
import Ember from 'ember';

const path = require('path');

const {inject:{service}, computed, String:{camelize}} = Ember;

export default Ember.Controller.extend({
  commander: service(),
  project: computed.alias('model'),

  models: [{
    name: '',
    attrs: [
      {name: '', transform: ''}
    ]
  }],

  transforms: computed('model.transforms.[]', function () {
    // default transforms https://guides.emberjs.com/v2.5.0/models/defining-models/#toc_transforms
    let transforms = ['', 'string', 'number', 'boolean', 'date', 'belongsTo', 'hasMany'];

    return transforms.concat(this.get('model.transforms').map(transformPath =>
      camelize(path.basename(transformPath, '.js'))));
  })
});
