exec = require('child_process').exec
spawn = require('child_process').spawn

task 'compile', 'Compiles coffee in app/coffee/ to js in app/js/', ->
  compile()

task 'test', 'Runs the tests unders test/', ->
  tests = spawn('./node_modules/karma/bin/karma', ['start', 'karma.conf.js'])

  tests.stdout.pipe(process.stdout)
  tests.stderr.pipe(process.stderr)
  tests.on 'exit', (status) ->
    if status is not 0
      process.exit(status);

compile = (callback) ->
  exec 'coffee -o app/js/ -c app/coffee/', (err, stdout, stderr) ->
    throw err if err
    console.log "Compiled coffee files"
    callback?()
