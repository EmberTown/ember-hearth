import Ember from 'ember';

const {inject} = Ember;

export default Ember.Route.extend({
  electron: inject.service(),

  model(){
    return this.store.peekAll('project');
  },

  actions: {
    showItemInFolder(path) {
      this.get('electron.shell').showItemInFolder(path);
    },
    openItem(path) {
      this.get('electron.shell').openItem(path);
    },
    openExternal(url){
      this.get('electron.shell').openExternal(url);
    }
  }
});
