require.config(
    baseUrl: 'coffee/',

    # alias libraries paths
    paths:
      'domReady': '../lib/requirejs/domReady',
      'angular': '../lib/angular/angular'
      'angular-route': '../lib/angular/angular-route'
      'angular-sanitize': '../lib/angular/angular-sanitize'
      'angular-hotkeys': '../lib/angular-hotkeys/hotkeys'
      'snap': '../lib/snap/snap.svg'
      'underscore': '../lib/underscore/underscore'
      'machina': '../lib/machina/machina'
      'config': '../config/client'
      'moment': '//cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.3/moment.min'

    # angular does not support AMD out of the box, put it in a shim
    shim:
      'angular':
        exports: 'angular'
      'angular-route':
        'deps': ['angular']
      'angular-sanitize':
        'deps': ['angular']
      'angular-hotkeys':
        'deps': ['angular']

    # kick start application
    deps: ['./bootstrap']
)
