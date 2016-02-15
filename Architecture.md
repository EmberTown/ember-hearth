# Architecture

## Overview

- **project** represents an ember project (app or addon)
- **command** represents a command that will be spawned via `child_process.spawn()`

- communication via [ipc-main](https://github.com/atom/electron/blob/master/docs/api/ipc-main.md) (server) 
  and [ipc-renderer](https://github.com/atom/electron/blob/master/docs/api/ipc-renderer.md) (client)

### Server (node + electron) `./cli/**/*.js`

- listens for client send events
- has access to the database
- emits project list on `hearth-ready`
- running commands  killed on `mainWindow.on('closed', …`
- listens for ipc events `hearth-add-project`, `hearth-remove-project`, `hearth-ready`, `hearth-init-project`, `hearth-run-cmd`, `hearth-kill-cmd`
  - `hearth-*-cmd`:
    - events for general purpose child_process command control
  - `heart-*-project`:
    - events for controlling projects

### Client (hearth ember app)

- ember service around `electron`, `ipc`
- `ipc` service mixes `Ember.Evented` and automatically sends messages to the node server

## API

- `push based` communication, where client only displays and server emits data (not request based (would be nice to have))
- client sends "requesting" events to server
- server pushes updates to client, which pushes data into store
- store propagates changes through client app, which in turn updates the ui through Embers bindings
- data from the server is usually used by having a computed property that filters the projects commands with specific bin, args, …:
  - getting the help (available commands): filter projects commands where `bin` equals `"ember"`, `name` equals `"help"` and `args` equals `"--json"`
  - getting commands that serves an ember app: filter project commands where `bin` equals `"ember"`, `name` equals `"s"`

### Project

- is persisted in a db (nedb)
- `hasMany` commands
- consists of name, path and metadata (which is generated at runtime, by reading the projects `package.json` and `.ember-cli`)

### Commands

- are't persisted
- `belongsTo` project
- once send to the server, they're spawned and stdout, stderr, … pushed to the clients `command` records

#### Example commands

**loading `ember help --json`**

```
store.createRecord('command', {
  bin: 'ember',
  id: uuid.v4(),
  name: 'help',
  args: ['--json'],
  project: model
});
```

**starting a command**

- command that represents `npm install clamp`:

```
store.createRecord('command', {
  bin: 'npm',
  name: 'install',
  args: ['clamp'],
  stdout: [],
  stderr: [],
  project: model
});
```

- to run the command:

```
ipc.trigger('hearth-run-cmd', this.get('store').serialize(command, {includeId: true}))
// or `commander.start(command)` via `commander` service
```

**killing a command**

- requires a previously created command:
```
ipc.trigger('hearth-kill-cmd', this.get('store').serialize(command, {includeId: true}))
// or `commander.stop(command)` via `commander` service
``` 
