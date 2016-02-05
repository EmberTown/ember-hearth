import Ember from 'ember';
let electron = requireNode('electron');

const {Evented} = Ember;

export default Ember.Service.extend(Evented, {
  on(name, target, method){
    this._super(...arguments);
    if (typeof target !== 'function') {
      electron.ipcRenderer.on(name, method.bind(target));
    } else {
      electron.ipcRenderer.on(name, target);
    }
  },
  trigger(name, ...args) {
    this._super(...arguments);
    electron.ipcRenderer.send(name, args);
  }
});
