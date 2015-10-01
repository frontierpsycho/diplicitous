require.config(
    baseUrl: 'coffee/',

    # alias libraries paths
    paths:
      'domReady': '../bower_components/requirejs-domready/domReady',
      'angular': '../bower_components/angular/angular'
      'angular-route': '../bower_components/angular-route/angular-route'
      'angular-sanitize': '../bower_components/angular-sanitize/angular-sanitize'
      'angular-hotkeys': '../bower_components/angular-hotkeys/build/hotkeys'
      'snap': '../bower_components/Snap.svg/dist/snap.svg'
      'underscore': '../lib/underscore/underscore'
      'lodash': '../bower_components/lodash/lodash'
      'machina': '../bower_components/machina/lib/machina'
      'moment': '../bower_components/moment/moment'
      'config': '../config/client'

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
