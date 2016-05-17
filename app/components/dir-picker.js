import Ember from 'ember';

const {inject} = Ember;

export default Ember.Component.extend({
  electron: inject.service(),
  path: '',
  actions: {
    setPath(){
      const dialog = this.get('electron.remote.dialog');
      const dirs = dialog.showOpenDialog({properties: ['openDirectory']});

      if (dirs.length) {
        this.set('path', dirs[0]);
        this.get('changedPath')(dirs[0]);
      }
    }
  }
});
