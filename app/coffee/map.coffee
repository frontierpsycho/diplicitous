define([
  'snap'
  'mapData'
], (
  Snap
  MapData
) ->
  'use strict'

  Map = ($scope, selector, svgPath) ->

    that = {}

    that.provinces = {}

    that.snap = Snap(selector)
    Snap.load(svgPath, (data) ->
      console.log "Loaded map in Map!"

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

      deregisterWatch = $scope.$watch('game', ->
        console.debug "Game loaded!", $scope.game.data.Id

        for provinceName,unit of $scope.game.data.Phase.Units
          provinceName = provinceName.replace '/', '-'

          that.colourProvince(provinceName, MapData.powers[unit.Nation].colour)

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
        console.warning "Cannot colour province #{abbr}: it does not exist!"

    that.hoverProvince = (abbr) ->
      province = that.provinces[abbr]

      if province?
        province.hover (event) ->
          this.attr
            "fill-opacity": "0.5"
        , (event) ->
          this.attr
            "fill-opacity": "0.8"
      else
        console.warning "Cannot add hover handlers to province #{abbr}: it does not exist!"

    return that

  return Map
)
