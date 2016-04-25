import { attrToArg } from 'ember-hearth/utils/model-maker';
import { module, test } from 'qunit';

module('Unit | Utility | model maker');

// Replace this with your real tests.
test('it works', function(assert) {
  let attr = { name: "testName", transform: "" };
  let result = attrToArg(attr);

  assert.ok(result);
});
