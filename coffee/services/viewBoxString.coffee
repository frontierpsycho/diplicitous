define([
  'lodash'
], (
  _
) ->
  'use strict'

  ViewBoxString = (viewBoxString) ->
    [this.x, this.y, this.width, this.height] = _.map(viewBoxString.split(" "), (v) -> parseFloat(v))

    return

  ViewBoxString.prototype.scroll = (x, y) ->
    this.x = x
    this.y = y

  ViewBoxString.prototype.zoom = (w, h) ->
    this.width = w
    this.height = y

  ViewBoxString.prototype.zoomPercent = (percent) ->
    this.width = this.width * (percent / 100)
    this.height = this.height * (percent / 100)

  ViewBoxString.prototype.toString = -> "#{this.x} #{this.y} #{this.width} #{this.height}"

  ViewBoxString
)
