define([
  'snap'
], (
  Snap
) ->
  'use strict'

  Map = ($scope, selector, svgPath) ->

    that = {}

    that.provinces = {}

    that.powerColors = 
      Austria:
        colour: "#B22222"
      England:
        colour: "#4B0082"
      France:
        colour: "#ADD8E6"
      Germany:
        colour: "#414141"
      Italy:
        colour: "#3E954A"
      Russia:
        colour: "#E5E5E5"
      Turkey:
        colour: "#F0E68C"

    that.snap = Snap(selector)
    Snap.load(svgPath, (data) ->
      console.log "Loaded map in Map!"

      data.select("#provinces").attr
        style: ""
      provinces = data.selectAll("#provinces path")
      for province in provinces

        that.provinces[province.attr("id")] = province

        province.attr
          style: ""
          fill: "#FFFFFF"
          "fill-opacity": "0"
      that.snap.append(data)

      deregisterWatch = $scope.$watch('game', ->
        console.debug "Game loaded!", $scope.game.data.Id

        for provinceName,unit of $scope.game.data.Phase.Units
          provinceName = provinceName.replace '/', '-'

          that.colourProvince(provinceName, that.powerColors[unit.Nation].colour)

          deregisterWatch()
      )
    )

    that.colourProvince = (abbr, colour) ->
      province = that.provinces[abbr]

      if province?
        province.attr
          style: ""
          fill: colour
          "fill-opacity": "0.8"
      else
        console.warning "Cannot colour province #{abbr}: it does not exist!"

    return that

  return Map
)
