{exec} = require 'child_process'


task 'compile', 'Compiles coffee in app/coffee/ to js in app/js/', ->
  compile()

task 'test', 'Runs the tests unders test/', ->
  exec './node_modules/karma/bin/karma start test/karma.conf.js', (err, stdout, stderr) ->
    throw err if err
    console.log "Done."

compile = (callback) ->
  exec 'coffee -o app/js/ -c app/coffee/', (err, stdout, stderr) ->
    throw err if err
    console.log "Compiled coffee files"
    callback?()
