define([
  'snap'
  'mapData'
], (
  Snap
  MapData
) ->
  'use strict'

  hover_in = (event) ->
    this.attr
      "fill-opacity": "0.5"

  hover_out = (event) ->
    this.attr
      "fill-opacity": "0.8"

  Map = ($scope, selector, svgPath) ->

    that = {
      provinces: {}
      loaded: false
    }

    that.snap = Snap(selector)
    Snap.load(svgPath, (data) ->
      data.select("#provinces").attr
        style: ""
      provinces = data.selectAll("#provinces path")
      for province in provinces
        provinceName = province.attr("id")

        that.provinces[provinceName] = province

        if provinceName in MapData.seas
          that.colourProvince(provinceName, "#FFFFFF", "0")
        else
          that.colourProvince(provinceName, MapData.powers.default.colour)

      that.snap.append(data)

      console.debug "Map loaded"
      $scope.$apply ->
        that.loaded = true

      deregisterWatch = $scope.$watch('game', ->
        console.debug "Game loaded!", $scope.game.data.Id

        for provinceName, unit of $scope.game.data.Phase.Units
          provinceName = provinceName.replace '/', '-'

          that.colourProvince(provinceName, MapData.powers[unit.Nation].colour)


          insertUnit = (provinceName, unit, snap) ->
            unitLayer = that.snap.select("svg #units")

            return (armyData) ->
              unitSVG = armyData.select("#body")
              if not unitSVG?
                unitSVG = armyData.select("#hull")

              unitBBox = unitSVG.getBBox()

              centerBBox = snap.select("##{provinceName}Center").getBBox()
              console.debug provinceName, unit

              unitLayer.append(unitSVG)
              t = new Snap.Matrix().translate(centerBBox.cx - (unitBBox.width/2), centerBBox.cy - (unitBBox.height/2))
              unitSVG.attr({
                "fill": MapData.powers[unit.Nation].colour
                "stroke-width": "2px"
              })

              unitSVG.transform(t)

          Snap.load("img/#{unit.Type}.svg", insertUnit(provinceName, unit, that.snap))

        deregisterWatch()
      )
    )

    that.colourProvince = (abbr, colour, opacity) ->
      opacity = opacity || "0.8"

      province = that.provinces[abbr]

      if province?
        province.attr
          style: ""
          fill: colour
          "fill-opacity": opacity
      else
        console.warn "Cannot colour province #{abbr}: it does not exist!"

    that.hoverProvince = (abbr) ->
      province = that.provinces[abbr]

      if province?
        province.hover hover_in, hover_out
      else
        console.warn "Cannot add hover handlers to province #{abbr}: it does not exist!"

    that.unhoverProvince = (abbr) ->
      province = that.provinces[abbr]

      if province?
        province.unhover hover_in, hover_out
      else
        console.warn "Cannot remove hover handlers to province #{abbr}: it does not exist!"

    that.clickProvince = (abbr, callback) ->
      province = that.provinces[abbr]

      if province?
        province.click (event) ->
          callback.bind(this)()
      else
        console.warn "Cannot add click handler to province #{abbr}: it does not exist!"

    return that

  return Map
)
