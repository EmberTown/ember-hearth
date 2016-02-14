import Ember from 'ember';

const {inject, RSVP} = Ember;

export default Ember.Route.extend({
  ajax: inject.service(),

  model(){
    return RSVP.all([
      this.get('ajax').request('http://emberobserver.com/api/addons'),
      this.get('ajax').request('http://emberobserver.com/api/categories')
    ]).then(([{addons}, {categories}]) => {
      // TODO: use cateogries and inline their addons
      return {
        addons,
        categories
      };
    });
  }
});
