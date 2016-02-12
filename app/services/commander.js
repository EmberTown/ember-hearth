import Ember from 'ember';

const {inject, RSVP, assert} = Ember;

function buildResolveFn(resolveMapName) {
  return function (ev, cmd) {
    let resolveMap = this.get(resolveMapName);
    if (resolveMap[cmd.id]) {
      resolveMap[cmd.id](...arguments);
      delete resolveMap[cmd.id];
    }
  };
}

export default Ember.Service.extend({
  ipc: inject.service(),
  store: inject.service(),

  _stopResolveMap: {},
  _startResolveMap: {},

  _callStopResolveFn: buildResolveFn('_stopResolveMap'),
  _callStartResolveFn: buildResolveFn('_startResolveMap'),

  init(){
    this._super(...arguments);

    // all the _call*ResolveFn are basically to resolve an earlier created promise after a server event is emitted
    this.get('ipc').on('cmd-close', this, this.get('_callStopResolveFn'));
    this.get('ipc').on('cmd-start', this, this.get('_callStartResolveFn'));
  },

  destroy(){
    this._super(...arguments);
    this.get('ipc').off('cmd-close', this, this.get('_callStopResolveFn'));
    this.get('ipc').off('cmd-start', this, this.get('_callStartResolveFn'));
  },

  storeResolveForCommand(resolver, command, resolve) {
    assert(`Must not contain a resolve fn for command ${command.get('id')}`, !this.get(resolver).hasOwnProperty(command.get('id')));
    this.get(resolver)[command.get('id')] = resolve;
  },

  start(command) {
    return new RSVP.Promise((resolve) => {
      this.storeResolveForCommand('_startResolveMap', command, resolve);
      this.get('ipc').trigger('hearth-run-cmd', this.get('store').serialize(command, {includeId: true}));
    });
  },

  stop(command) {
    return new RSVP.Promise((resolve) => {
      this.storeResolveForCommand('_stopResolveMap', command, resolve);
      this.get('ipc').trigger('hearth-kill-cmd', this.get('store').serialize(command, {includeId: true}));
    });
  },

  restart(command){
    return this.stop(command).then(() => {
      command.reset();
      this.start(command);
    });
  }
});
