define([
  'objects/mapData'
  'underscore'
], (
  MapData
  _
) ->
  'use strict'

  Province = (abbr, path) ->
    that = {
      path: path
    }

    that.addClass = (klass) ->
      that.path.node.classList.add(klass)

    that.removeClass = (klass) ->
      that.path.node.classList.remove(klass)

    abbrTuple = abbr.split("-")

    if abbrTuple.length > 1
      # we have a coast
      that.addClass("coast")
    else if abbr in MapData.seas
      that.addClass("sea")

    that
)
