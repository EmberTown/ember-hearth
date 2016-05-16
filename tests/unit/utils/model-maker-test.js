import {attrToArg} from 'ember-hearth/utils/model-maker';
import {module, test} from 'qunit';

module('Unit | Utility | model maker');

test('#attrToArg', function (assert) {
  [
    [{name: "body", transform: "string"}, 'body:string'],
    [{name: "foo-bar", transform: "boolean"}, 'foo-bar:boolean'],
    [{name: "foo_bar", transform: "hasMany", relationshipName: 'foo-bar'}, 'foo_bar:has-many:foo-bar']
  ].forEach(([attr, expected]) =>
    assert.equal(attrToArg(attr), expected, `transforms to "${expected}"`));
});
