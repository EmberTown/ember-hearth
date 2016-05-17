'use strict';

const Term = require('./index');

class Win32Term extends Term {
  spawn(bin, args, spawnOptions) {
    // patch windows spawn call
    //TODO: maybe not expect `node` to exist
    args.unshift('node', bin);
    bin = 'powershell.exe';
    return super.spawn(bin, args, spawnOptions);
  }

  buildTermLaunchArgs(scriptPath) {
    return [process.env.ComSpec, ['/C', `start ${process.env.ComSpec} /C ${scriptPath}`]];
  }

  buildRunScript(bin, args, projectDir) {
    const suffix = '.cmd';

    // based on npm generated bin/command.cmd
    const scriptContent = `

cd /d ${projectDir}

@IF EXIST "%~dp0\\node.exe" (
  "%~dp0\\node.exe" "${bin}"  "${args.join('" "')}"
) ELSE (
  @SETLOCAL
  @SET PATHEXT=%PATHEXT:;.JS;=;%
  node  "${bin}"  "${args.join('"  "')}"
)
`;

    return {
      content: scriptContent,
      suffix
    };
  }
}

module.exports = Win32Term;
