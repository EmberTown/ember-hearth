module.exports = {
  root: true,
  parser: "babel-eslint",
  parserOptions: {
    ecmaVersion: 6,
    sourceType: 'module'
  },
  extends: 'eslint:recommended',
  env: {
    'browser': true,
    'node': true,
    'es6': true
  },
  rules: {
    'no-console': 0,
    'no-multi-spaces': 2,
    'one-var': ['error', 'never'],
    'indent': ['error', 2]
  },
  globals: {
    'requireNode': true,
    'uuid': true
  }
};
