import Ember from 'ember';
let bower = requireNode('bower');

const { RSVP } = Ember;

export default Ember.Route.extend({
  model() {
    return new RSVP.Promise((resolve, reject) => {
      bower.commands.list().on('end', results => {
        console.log(results);
        resolve(results);
      });
    });
  }
});
