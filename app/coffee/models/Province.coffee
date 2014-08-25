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
      coasts: null
      parent: null
    }

    that.addClass = (klass) ->
      that.path.node.classList.add(klass)

    that.removeClass = (klass) ->
      that.path.node.classList.remove(klass)

    that.setNation = (nation) ->
      that.nation = nation
      unless that.abbr in MapData.seas
        that.addClass(nation)

      if that.coasts
        for name, province of that.coasts
          province.setNation(nation)

    that.setCoasts = (coasts) ->
      if not _.isEmpty(coasts)
        this.coasts = {}
      for name, province of coasts
        this.coasts[name] = province
        province.setParent(this)

    that.setParent = (parent) ->
      that.parent = parent

    abbrTuple = abbr.split("-")

    if abbrTuple.length > 1
      # we have a coast
      that.addClass("coast")
    else if abbr in MapData.seas
      that.addClass("sea")

    that
)
