'use strict';

const LinuxTerm = require('./linux');

class DarwinTerm extends LinuxTerm{
  buildTermLaunchArgs(scriptPath) {
    return ['osascript', ['-e', `tell app "Terminal" to do script "eval $SHELL ${scriptPath}"`]];
  }
}

module.exports = DarwinTerm;
