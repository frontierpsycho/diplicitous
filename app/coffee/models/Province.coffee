define([
  'models/mapData'
  'underscore'
], (
  MapData
  _
) ->
  'use strict'

  Province = (abbr, path, nation) ->
    that = {
      abbr: abbr
      path: path
      nation: nation
    }

    that.addClass = (klass) ->
      that.path.node.classList.add(klass)

    that.removeClass = (klass) ->
      that.path.node.classList.remove(klass)

    that.setNation = (nation) ->
      that.nation = nation
      unless that.abbr in MapData.seas
        that.addClass(nation)

    abbrTuple = abbr.split("-")

    if abbrTuple.length > 1
      # we have a coast
      that.addClass("coast")
    else if abbr in MapData.seas
      that.addClass("sea")

    that
)
