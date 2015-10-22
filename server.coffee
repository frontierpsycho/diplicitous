path = require('path')
compression = require('compression')
express = require('express')
morgan = require('morgan')
coffeeMiddleware = require 'express-coffee-script'
minify = require('express-minify')

app = express()

app.use(compression())

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

server = app.listen(8002, ->
  host = server.address().address
  port = server.address().port
  console.log 'Example app listening at http://%s:%s', host, port
  return
)
