var allTestFiles = [];
var TEST_REGEXP = /Spec\.js/i;

Object.keys(window.__karma__.files).forEach(function(file) {
  if (TEST_REGEXP.test(file)) {
    allTestFiles.push(file);
  }
});

require.config({
  // Karma serves files under /base, which is the basePath from your config file
  baseUrl: '/base/coffee',

  paths: {
    'angular': '../lib/angular/angular',
    'underscore': '../lib/underscore/underscore',
    'machina': '../lib/machina/machina',
    'domReady': '../lib/requirejs/domReady',
    'angular-route': '../lib/angular/angular-route',
    'angular-sanitize': '../lib/angular/angular-sanitize',
    'snap': '../lib/snap/snap.svg'
  },

  shim: {
    'underscore': {
      exports: '_'
    },
    'angular': {
      exports: 'angular'
    },
    'angular-route': {
      deps: ['angular']
    },
    'angular-sanitize': {
      deps: ['angular']
    }
  },

  // dynamically load all test files
  deps: allTestFiles,

  // we have to kickoff jasmine, as it is asynchronous
  callback: window.__karma__.start
});
