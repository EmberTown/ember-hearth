import Ember from 'ember';

const {inject, computed} = Ember;

export default Ember.Controller.extend({
  ipc: inject.service(),

  isLoading: computed('model.help', function(){
    return !this.get('model').hasOwnProperty('help');
  }),

  actions: {
    startServer(){
      let model = this.get('model');
      this.get('ipc').trigger('hearth-start-app', model.toJSON({includeId: true}));
    },
    stopServer(){
      let model = this.get('model');
      this.get('ipc').trigger('hearth-stop-app', model.toJSON({includeId: true}));
    }
  }
});
