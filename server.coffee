path = require('path')
compression = require('compression')
express = require('express')
morgan = require('morgan')
coffeeMiddleware = require 'express-coffee-script'

argv = require('yargs').argv

app = express()

app.use(compression())

if argv.m
  minify = require('express-minify')
  app.use(minify(
    coffee_match: /\/coffee/
  ))

app.use(morgan('dev'))

app.use('/js', coffeeMiddleware({
  src: 'coffee'
  dest: 'js'
  prefix: '/js'
}))

app.use(express.static('.'))

port = parseInt(process.argv[2]) || 8000
server = app.listen(port, ->
  host = server.address().address
  port = server.address().port
  console.log 'Diplicity listening at http://%s:%s', host, port
  return
)
