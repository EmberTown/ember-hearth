import Ember from 'ember';

export function concat(params, {separator}) {
  return params.concat(separator || '');
}

export default Ember.Helper.helper(concat);
