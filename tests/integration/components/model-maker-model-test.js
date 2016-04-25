import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('model-maker-model', 'Integration | Component | model maker model', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{model-maker-model}}`);

  // assert.equal(this.$().text().trim(), '');
  assert.ok(true);
});
