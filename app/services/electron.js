import Ember from 'ember';
let electron = requireNode('electron');

let fields = Object.keys(electron).reduce((all, key) => {
  all[key] = electron[key];
  return all;
}, {});

export default Ember.Service.extend(fields);
