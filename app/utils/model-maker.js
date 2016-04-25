import Ember from 'ember';

const {String:{dasherize}} = Ember;

function attrToArg(attr) {
  const hasRelationship = ['belongsTo', 'hasMany'].indexOf(attr.transform) !== -1;
  let arg = `${attr.name}:${dasherize(attr.transform)}`;

  if (hasRelationship) {
    arg += `:${attr.relationshipName}`;
  }

  return arg;
}

export {attrToArg};
