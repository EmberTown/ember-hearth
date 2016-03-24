'use strict';

const spawn = require('child_process').spawn;
const cp = require('child_process');
const fs = require('fs');
const temp = require('temp');
const quickTemp = require('quick-temp');

class Term {
  constructor(){

  }
  spawn(bin, args, spawnOptions) {
    return spawn(bin, args, spawnOptions);
  }

  buildTermLaunchArgs(scriptPath) {
    throw 'not implemented';
  }

  buildRunScript(bin, args, projectDir) {
    throw 'not implemented';
  }

  buildCommandScript(bin, args, projectDir) {
    let script = this.buildRunScript(bin, args, projectDir)
    const content = script.content;
    const suffix = script.suffix;

    return new Promise((resolve, reject) => {
      var tmp = {};

      quickTemp.makeOrReuse(tmp, 'tmp');

      temp.open({dir: tmp.tmp, suffix}, function (err, info) {
        if (!err) {
          fs.write(info.fd, content);
          fs.close(info.fd, function (err) {
            if (err) {
              reject(err);
            } else {
              resolve(info.path);
            }
          });
        } else {
          reject(err);
        }
      });
    });
  }

  launchTermCommand(bin, args, spawnOptions) {
    return this.buildCommandScript(bin, args, spawnOptions.cwd)
      .then(scriptPath =>
        cp.spawn.apply(cp, this.buildTermLaunchArgs(scriptPath), spawnOptions));
  }

  static forPlatform(platform) {
    // gief default params :(
    platform = platform || process.platform;
    const platformTerm = {
      'win32': './win32',
      'darwin': './darwin',
      'linux': './linux'
    };

    let term;
    if (platformTerm.hasOwnProperty(platform)) {
      term = new (require(platformTerm[platform]))();
    } else {
      throw `Unsupported process platform. Please open an issue to add support for ${platform}`;
    }
    return term;
  }
}

module.exports = Term;
