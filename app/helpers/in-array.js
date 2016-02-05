import Ember from 'ember';

export function inArray([array, string]/*, hash*/) {
  return array && array.indexOf(string) !== -1;
}

export default Ember.Helper.helper(inArray);
