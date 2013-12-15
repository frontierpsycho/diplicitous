# angular-coffee-seed
## The seed for AngularJS apps in coffeescript

This project is a [coffeescript](http://coffeescript.org/) port of the [angular-seed](https://github.com/angular/angular-seed) project.

I have been inspired by the [angular-seed-coffeescript](https://github.com/OClement/angular-seed-coffeescript) project. I however disliked the browser coffee compilation, so I wrote my own.

## How do I include a `.coffee` file in html?

You don't. Just include a `.js` file. `./scripts/web-server.js` will search for a `.coffee` file and send it compiled.

## How do I include a `.js` file?

Feel free to. If a `.coffee` file is not found and `.js` is, it will be sent untouched.

## Tests

Both `.coffee` and `.js` tests work.

## Why another coffee seed?

This seed uses server-side compilation. While it may take some time (miliseconds?), there is no need for any workarounds that arise from compiling in the browser.

## Compilation takes too long

Get a SSD drive.
