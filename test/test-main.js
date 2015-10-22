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
    'angular': '../bower_components/angular/angular',
    'angular-route': '../bower_components/angular-route/angular-route',
    'angular-sanitize': '../bower_components/angular-sanitize/angular-sanitize',
    'lodash': '../bower_components/lodash/lodash',
    'machina': '../bower_components/machina/lib/machina',
    'domReady': '../bower_components/requirejs-domready/domReady',
    'snap': '../bower_components/Snap.svg/dist/snap.svg'
  },

  shim: {
    'lodash': {
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
