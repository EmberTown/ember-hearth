# Ember Hearth
Ember Hearth is an application used to manage Ember projects.

**Warning: Ember Hearth is alpha software and may misbehave.**

## Goals
Ember Hearth aspires to allow new users to do all they need to do to run Ember projects without touching the command line.

## Features
* Installs all needed tools automatically ([node.js](http://nodejs.org), [NPM](http://npmjs.com), [Bower](http://bower.io), [PhantomJS](http://phantomjs.org), [Ember-CLI](http://ember-cli.com))
* Create new Ember projects
* Manage existing Ember projects
* Run a local server
* Create development and release builds

## Installing
Go to [ember.town/ember-hearth](http://ember.town/ember-hearth) and download Hearth from there. Double click to extract and move Ember Hearth.app to your Applications folder.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md)

### Running in Xcode
1. Clone git project
2. Run `pod install` in the project folder
3. Open Ember Hearth.xcworkspace

## Troubleshooting

### Node/NPM/Ember-cli is not available in my terminal
If you're using something else than bash for your shell, the tools installed through Ember Hearth might not be in your path. This can be fixed by adding `export PATH=$HOME/local/bin:$PATH` to your config (for example  `~/.zshrc` for zsh).
