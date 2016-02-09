import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('project', function() {
    this.route('detail', {path: '/:project_id'}, function() {
      this.route('statistics');
      this.route('actions');
      this.route('log');
    });
    this.route('new');
  });
});

export default Router;
