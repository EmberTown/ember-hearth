import Ember from 'ember';

const {inject} = Ember;

export default Ember.Route.extend({
  electron: inject.service(),

  model(){
    return this.store.peekAll('project');
  },

  actions: {
    openExternal(url){
      this.get('electron.shell').openExternal(url);
    }
  }
});
