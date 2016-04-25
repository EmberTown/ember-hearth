import Ember from 'ember';

const {$:{extend}, inject:{service}} = Ember;

const DEFAULT_CLI_CONFIG = {
  "disableAnalytics": false,
  "port": 4200,
  "testPort": 7357,
  "proxy": "",
  "host": "",
  "liveReload": true,
  "environment": "",
  "checkForUpdates": true
};
const CLI_FIELDS = Object.keys(DEFAULT_CLI_CONFIG);

export default Ember.Controller.extend({
  ipc: service(),

  reset(){
    this._super(...arguments);

    this.setProperties(extend({}, DEFAULT_CLI_CONFIG, this.get('model.cli')));
  },

  actions: {
    saveChanges(/* ev */){
      const cli = this.getProperties(CLI_FIELDS);
      const project = this.get('model');

      project.set('cli', cli);

      this.get('ipc').trigger('hearth-update-project', this.get('store').serialize(project, {includeId: true}));
    }
  }
});
