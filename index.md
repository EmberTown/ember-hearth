---
layout: default
---
# Ember Hearth
Ember Hearth is an application used to manage Ember projects.

**Warning: Ember Hearth is alpha software and may misbehave.**

<img width="666" src="{{"/images/screenshot 0.1.0.png" | prepend: site.baseurl}}" alt="The glory that is Ember Hearth"/>

## Goals
Ember Hearth aspires to allow new users to do all they need to do to run Ember projects without touching the command line.

## Features
* Installs all needed tools automatically ([node.js](http://nodejs.org), [NPM](http://npmjs.com), [Bower](http://bower.io), [PhantomJS](http://phantomjs.org) and [Ember-CLI](http://ember-cli.com))
* Create new Ember projects
* Manage existing Ember projects
* Run a local server
* Create development and release builds

## Installing
Download [the latest release of Hearth][releaseurl]. Double click to extract and move `Ember Hearth.app` to your Applications folder.

[releaseurl]: {%for release in site.categories.release limit:1 %}{{release.package_url}}{% endfor %}
