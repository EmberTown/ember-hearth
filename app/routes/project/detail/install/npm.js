import Ember from 'ember';

export default Ember.Route.extend({

  model(){
    // TODO: load list of npm packages
    return [{
      "_args": [
        [
          "abbrev@1",
          "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/nopt"
        ]
      ],
      "_from": "abbrev@>=1.0.0 <2.0.0",
      "_id": "abbrev@1.0.7",
      "_inCache": true,
      "_installable": true,
      "_location": "/abbrev",
      "_nodeVersion": "2.0.1",
      "_npmUser": {
        "email": "isaacs@npmjs.com",
        "name": "isaacs"
      },
      "_npmVersion": "2.10.1",
      "_phantomChildren": {},
      "_requested": {
        "name": "abbrev",
        "raw": "abbrev@1",
        "rawSpec": "1",
        "scope": null,
        "spec": ">=1.0.0 <2.0.0",
        "type": "range"
      },
      "_requiredBy": [
        "/nopt",
        "/touch/nopt"
      ],
      "_resolved": "http://10.35.10.12:4873/abbrev/-/abbrev-1.0.7.tgz",
      "_shasum": "5b6035b2ee9d4fb5cf859f08a9be81b208491843",
      "_shrinkwrap": null,
      "_spec": "abbrev@1",
      "_where": "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/nopt",
      "author": {
        "email": "i@izs.me",
        "name": "Isaac Z. Schlueter"
      },
      "bugs": {
        "url": "https://github.com/isaacs/abbrev-js/issues"
      },
      "dependencies": {},
      "description": "Like ruby's abbrev module, but in js",
      "devDependencies": {
        "tap": "^1.2.0"
      },
      "directories": {},
      "dist": {
        "shasum": "5b6035b2ee9d4fb5cf859f08a9be81b208491843",
        "tarball": "http://registry.npmjs.org/abbrev/-/abbrev-1.0.7.tgz"
      },
      "gitHead": "821d09ce7da33627f91bbd8ed631497ed6f760c2",
      "homepage": "https://github.com/isaacs/abbrev-js#readme",
      "license": "ISC",
      "main": "abbrev.js",
      "maintainers": [
        {
          "email": "i@izs.me",
          "name": "isaacs"
        }
      ],
      "name": "abbrev",
      "optionalDependencies": {},
      "readme": "ERROR: No README data found!",
      "repository": {
        "type": "git",
        "url": "git+ssh://git@github.com/isaacs/abbrev-js.git"
      },
      "scripts": {
        "test": "tap test.js --cov"
      },
      "version": "1.0.7"
    }
      ,{
        "_args": [
          [
            "accepts@~1.3.1",
            "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/compression"
          ]
        ],
        "_from": "accepts@>=1.3.1 <1.4.0",
        "_id": "accepts@1.3.1",
        "_inCache": true,
        "_installable": true,
        "_location": "/accepts",
        "_npmUser": {
          "email": "doug@somethingdoug.com",
          "name": "dougwilson"
        },
        "_npmVersion": "1.4.28",
        "_phantomChildren": {},
        "_requested": {
          "name": "accepts",
          "raw": "accepts@~1.3.1",
          "rawSpec": "~1.3.1",
          "scope": null,
          "spec": ">=1.3.1 <1.4.0",
          "type": "range"
        },
        "_requiredBy": [
          "/compression"
        ],
        "_resolved": "http://10.35.10.12:4873/accepts/-/accepts-1.3.1.tgz",
        "_shasum": "dc295faf85024e05b04f5a6faf5eec1d1fd077e5",
        "_shrinkwrap": null,
        "_spec": "accepts@~1.3.1",
        "_where": "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/compression",
        "bugs": {
          "url": "https://github.com/jshttp/accepts/issues"
        },
        "contributors": [
          {
            "email": "doug@somethingdoug.com",
            "name": "Douglas Christopher Wilson"
          },
          {
            "email": "me@jongleberry.com",
            "name": "Jonathan Ong",
            "url": "http://jongleberry.com"
          }
        ],
        "dependencies": {
          "mime-types": "~2.1.9",
          "negotiator": "0.6.0"
        },
        "description": "Higher-level content negotiation",
        "devDependencies": {
          "istanbul": "0.4.2",
          "mocha": "~1.21.5"
        },
        "directories": {},
        "dist": {
          "shasum": "dc295faf85024e05b04f5a6faf5eec1d1fd077e5",
          "tarball": "http://registry.npmjs.org/accepts/-/accepts-1.3.1.tgz"
        },
        "engines": {
          "node": ">= 0.6"
        },
        "files": [
          "LICENSE",
          "HISTORY.md",
          "index.js"
        ],
        "gitHead": "6551051596cfcbd7aaaf9f02af8f487ce83cbf00",
        "homepage": "https://github.com/jshttp/accepts",
        "keywords": [
          "content",
          "negotiation",
          "accept",
          "accepts"
        ],
        "license": "MIT",
        "maintainers": [
          {
            "email": "jonathanrichardong@gmail.com",
            "name": "jongleberry"
          },
          {
            "email": "federomero@gmail.com",
            "name": "federomero"
          },
          {
            "email": "doug@somethingdoug.com",
            "name": "dougwilson"
          },
          {
            "email": "fishrock123@rocketmail.com",
            "name": "fishrock123"
          },
          {
            "email": "tj@vision-media.ca",
            "name": "tjholowaychuk"
          },
          {
            "email": "mscdex@mscdex.net",
            "name": "mscdex"
          },
          {
            "email": "shtylman@gmail.com",
            "name": "defunctzombie"
          }
        ],
        "name": "accepts",
        "optionalDependencies": {},
        "readme": "ERROR: No README data found!",
        "repository": {
          "type": "git",
          "url": "git+https://github.com/jshttp/accepts.git"
        },
        "scripts": {
          "test": "mocha --reporter spec --check-leaks --bail test/",
          "test-cov": "istanbul cover node_modules/mocha/bin/_mocha -- --reporter dot --check-leaks test/",
          "test-travis": "istanbul cover node_modules/mocha/bin/_mocha --report lcovonly -- --reporter spec --check-leaks test/"
        },
        "version": "1.3.1"
      }
      ,{
        "_args": [
          [
            "acorn@^1.0.3",
            "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/detective"
          ]
        ],
        "_from": "acorn@>=1.0.3 <2.0.0",
        "_id": "acorn@1.2.2",
        "_inCache": true,
        "_installable": true,
        "_location": "/acorn",
        "_npmUser": {
          "email": "marijnh@gmail.com",
          "name": "marijn"
        },
        "_npmVersion": "1.4.21",
        "_phantomChildren": {},
        "_requested": {
          "name": "acorn",
          "raw": "acorn@^1.0.3",
          "rawSpec": "^1.0.3",
          "scope": null,
          "spec": ">=1.0.3 <2.0.0",
          "type": "range"
        },
        "_requiredBy": [
          "/detective"
        ],
        "_resolved": "http://10.35.10.12:4873/acorn/-/acorn-1.2.2.tgz",
        "_shasum": "c8ce27de0acc76d896d2b1fad3df588d9e82f014",
        "_shrinkwrap": null,
        "_spec": "acorn@^1.0.3",
        "_where": "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/detective",
        "bin": {
          "acorn": "./bin/acorn"
        },
        "bugs": {
          "url": "https://github.com/marijnh/acorn/issues"
        },
        "contributors": [
          {
            "name": "List of Acorn contributors. Updated before every release."
          },
          {
            "name": "Adrian Rakovsky"
          },
          {
            "name": "Alistair Braidwood"
          },
          {
            "name": "Andres Suarez"
          },
          {
            "name": "Aparajita Fishman"
          },
          {
            "name": "Arian Stolwijk"
          },
          {
            "name": "Artem Govorov"
          },
          {
            "name": "Brandon Mills"
          },
          {
            "name": "Charles Hughes"
          },
          {
            "name": "Conrad Irwin"
          },
          {
            "name": "David Bonnet"
          },
          {
            "name": "Forbes Lindesay"
          },
          {
            "name": "Gilad Peleg"
          },
          {
            "name": "impinball"
          },
          {
            "name": "Ingvar Stepanyan"
          },
          {
            "name": "Jiaxing Wang"
          },
          {
            "name": "Johannes Herr"
          },
          {
            "name": "Jürg Lehni"
          },
          {
            "name": "keeyipchan"
          },
          {
            "name": "krator"
          },
          {
            "name": "Marijn Haverbeke"
          },
          {
            "name": "Martin Carlberg"
          },
          {
            "name": "Mathias Bynens"
          },
          {
            "name": "Mathieu 'p01' Henri"
          },
          {
            "name": "Max Schaefer"
          },
          {
            "name": "Max Zerzouri"
          },
          {
            "name": "Mihai Bazon"
          },
          {
            "name": "Mike Rennie"
          },
          {
            "name": "Nick Fitzgerald"
          },
          {
            "name": "Oskar Schöldström"
          },
          {
            "name": "Paul Harper"
          },
          {
            "name": "Peter Rust"
          },
          {
            "name": "PlNG"
          },
          {
            "name": "r-e-d"
          },
          {
            "name": "Rich Harris"
          },
          {
            "name": "Sebastian McKenzie"
          },
          {
            "name": "zsjforcn"
          }
        ],
        "dependencies": {},
        "description": "ECMAScript parser",
        "devDependencies": {
          "babelify": "^5.0.4",
          "browserify": "^9.0.3",
          "browserify-derequire": "^0.9.4",
          "unicode-7.0.0": "~0.1.5"
        },
        "directories": {},
        "dist": {
          "shasum": "c8ce27de0acc76d896d2b1fad3df588d9e82f014",
          "tarball": "http://registry.npmjs.org/acorn/-/acorn-1.2.2.tgz"
        },
        "engines": {
          "node": ">=0.4.0"
        },
        "gitHead": "0857d8bb9c3c05e6c8fac9e83fddaefc4f43816f",
        "homepage": "https://github.com/marijnh/acorn",
        "license": "MIT",
        "main": "dist/acorn.js",
        "maintainers": [
          {
            "email": "marijnh@gmail.com",
            "name": "marijn"
          }
        ],
        "name": "acorn",
        "optionalDependencies": {},
        "readme": "ERROR: No README data found!",
        "repository": {
          "type": "git",
          "url": "git+https://github.com/marijnh/acorn.git"
        },
        "scripts": {
          "prepublish": "bin/prepublish.sh",
          "test": "node test/run.js"
        },
        "version": "1.2.2"
      }
      ,{
        "_args": [
          [
            "after@0.8.1",
            "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/engine.io-parser"
          ]
        ],
        "_from": "after@0.8.1",
        "_id": "after@0.8.1",
        "_inCache": true,
        "_installable": true,
        "_location": "/after",
        "_npmUser": {
          "email": "raynos2@gmail.com",
          "name": "raynos"
        },
        "_npmVersion": "1.2.25",
        "_phantomChildren": {},
        "_requested": {
          "name": "after",
          "raw": "after@0.8.1",
          "rawSpec": "0.8.1",
          "scope": null,
          "spec": "0.8.1",
          "type": "version"
        },
        "_requiredBy": [
          "/engine.io-client-pure/engine.io-parser",
          "/engine.io-parser",
          "/engine.io-pure/engine.io-parser"
        ],
        "_resolved": "http://10.35.10.12:4873/after/-/after-0.8.1.tgz",
        "_shasum": "ab5d4fb883f596816d3515f8f791c0af486dd627",
        "_shrinkwrap": null,
        "_spec": "after@0.8.1",
        "_where": "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/engine.io-parser",
        "author": {
          "email": "raynos2@gmail.com",
          "name": "Raynos"
        },
        "bugs": {
          "url": "https://github.com/Raynos/after/issues"
        },
        "contributors": [
          {
            "email": "raynos2@gmail.com",
            "name": "Raynos",
            "url": "http://raynos.org"
          }
        ],
        "dependencies": {},
        "description": "after - tiny flow control",
        "devDependencies": {
          "mocha": "~1.8.1"
        },
        "directories": {},
        "dist": {
          "shasum": "ab5d4fb883f596816d3515f8f791c0af486dd627",
          "tarball": "http://registry.npmjs.org/after/-/after-0.8.1.tgz"
        },
        "homepage": "https://github.com/Raynos/after#readme",
        "keywords": [
          "flowcontrol",
          "after",
          "flow",
          "control",
          "arch"
        ],
        "maintainers": [
          {
            "email": "raynos2@gmail.com",
            "name": "raynos"
          },
          {
            "email": "shtylman@gmail.com",
            "name": "shtylman"
          }
        ],
        "name": "after",
        "optionalDependencies": {},
        "readme": "ERROR: No README data found!",
        "repository": {
          "type": "git",
          "url": "git://github.com/Raynos/after.git"
        },
        "scripts": {
          "test": "mocha --ui tdd --reporter spec test/*.js"
        },
        "version": "0.8.1"
      }
      ,{
        "_args": [
          [
            "align-text@^0.1.3",
            "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/center-align"
          ]
        ],
        "_from": "align-text@>=0.1.3 <0.2.0",
        "_id": "align-text@0.1.4",
        "_inCache": true,
        "_installable": true,
        "_location": "/align-text",
        "_nodeVersion": "5.5.0",
        "_npmOperationalInternal": {
          "host": "packages-9-west.internal.npmjs.com",
          "tmp": "tmp/align-text-0.1.4.tgz_1454377856920_0.9624228512402624"
        },
        "_npmUser": {
          "email": "snnskwtnb@gmail.com",
          "name": "shinnn"
        },
        "_npmVersion": "3.6.0",
        "_phantomChildren": {},
        "_requested": {
          "name": "align-text",
          "raw": "align-text@^0.1.3",
          "rawSpec": "^0.1.3",
          "scope": null,
          "spec": ">=0.1.3 <0.2.0",
          "type": "range"
        },
        "_requiredBy": [
          "/center-align",
          "/right-align"
        ],
        "_resolved": "https://registry.npmjs.org/align-text/-/align-text-0.1.4.tgz",
        "_shasum": "0cd90a561093f35d0a99256c22b7069433fad117",
        "_shrinkwrap": null,
        "_spec": "align-text@^0.1.3",
        "_where": "/mnt/err/code/git/private/mkp-ember-hearth/node_modules/center-align",
        "author": {
          "name": "Jon Schlinkert",
          "url": "https://github.com/jonschlinkert"
        },
        "bugs": {
          "url": "https://github.com/jonschlinkert/align-text/issues"
        },
        "dependencies": {
          "kind-of": "^3.0.2",
          "longest": "^1.0.1",
          "repeat-string": "^1.5.2"
        },
        "description": "Align the text in a string.",
        "devDependencies": {
          "mocha": "*",
          "should": "*",
          "word-wrap": "^1.0.3"
        },
        "directories": {},
        "dist": {
          "shasum": "0cd90a561093f35d0a99256c22b7069433fad117",
          "tarball": "http://registry.npmjs.org/align-text/-/align-text-0.1.4.tgz"
        },
        "engines": {
          "node": ">=0.10.0"
        },
        "files": [
          "index.js"
        ],
        "gitHead": "7f08e823a54c6bda319d875895813537a66a4c5e",
        "homepage": "https://github.com/jonschlinkert/align-text",
        "keywords": [
          "align",
          "align-center",
          "alignment",
          "center",
          "center-align",
          "indent",
          "pad",
          "padding",
          "right",
          "right-align",
          "text",
          "typography"
        ],
        "license": "MIT",
        "main": "index.js",
        "maintainers": [
          {
            "email": "github@sellside.com",
            "name": "jonschlinkert"
          },
          {
            "email": "snnskwtnb@gmail.com",
            "name": "shinnn"
          }
        ],
        "name": "align-text",
        "optionalDependencies": {},
        "readme": "ERROR: No README data found!",
        "repository": {
          "type": "git",
          "url": "git://github.com/jonschlinkert/align-text.git"
        },
        "scripts": {
          "test": "mocha"
        },
        "version": "0.1.4"
      }
    ];
  }
});
