require.config(
    # alias libraries paths
    paths:
      'domReady': '../lib/requirejs/domReady',
      'angular': '../lib/angular/angular'
      'angular-route': '../lib/angular/angular-route'
      'angular-sanitize': '../lib/angular/angular-sanitize'
      'snap': '../lib/snap/snap.svg'
      'underscore': '../lib/underscore/underscore'
      'machina': '../lib/machina/machina'

    # angular does not support AMD out of the box, put it in a shim
    shim:
      'angular':
        exports: 'angular'

    # kick start application
    deps: ['./bootstrap']
)
