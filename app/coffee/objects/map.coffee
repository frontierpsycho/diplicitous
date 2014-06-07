define([
  'snap'
  'objects/mapData'
], (
  Snap
  MapData
) ->
  'use strict'

  hover_in = (event) ->
    this.node.classList.add("active")

  hover_out = (event) ->
    this.node.classList.remove("active")

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
          province.node.classList.add("sea")

      that.snap.append(data)

      s = Snap("#{selector} svg")

      that.createOrders(s)

      console.debug "Map loaded"
      $scope.$apply ->
        that.loaded = true

      deregisterWatch = $scope.$watch('game', ->
        console.debug "Game loaded!", $scope.game.Id

        for provinceName, unit of $scope.game.Phase.Units
          provinceName = provinceName.replace '/', '-'

          that.colourProvince(provinceName, MapData.powers[unit.Nation].colour)

          province = that.provinces[provinceName]
          province.node.classList.add(unit.Nation)

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

    that.activateOrders = (abbr) ->
      provinceCenter = Snap.select("##{abbr}Center").getBBox()

      Snap.select("#orderGroup").transform("t#{provinceCenter.x},#{provinceCenter.y}")

    that.hideOrders = ->
      Snap.select("#orderGroup").transform("t-5000,-5000")

    that.colourProvince = (abbr, colour, opacity) ->
      opacity = opacity || "0.8"

      province = that.provinces[abbr]

      if province?
        province.attr
          style: ""
          #fill: colour
          #"fill-opacity": opacity
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
        hover_out.call(province)
      else
        console.warn "Cannot remove hover handlers to province #{abbr}: it does not exist!"

    that.clickProvince = (abbr, callback) ->
      province = that.provinces[abbr]

      if province?
        province.click (event) ->
          callback.bind(this)()
      else
        console.warn "Cannot add click handler to province #{abbr}: it does not exist!"

    that.createOrders = (snap) ->
      orders = {}

      for orderName in ["Move", "Support", "Hold"]
        c = snap.circle(0, 0, 35).attr
          fill: "rgb(236, 240, 241)",
          stroke: "#1f2c39",
          strokeWidth: 3

        text = snap.text(0, 0, orderName[0])
        text.attr({
            'font-size': 50
        })

        b = text.getBBox()

        c.attr
          cx: b.cx
          cy: b.cy

        orders[orderName] = snap.group(c, text).attr({
          id: "order-#{orderName}"
        })

        orders[orderName].click ((name) ->
          return ->
            $scope.lieutenant.fsm.handle 'chose.order', name
        )(orderName)

      orderRadius = 100

      # set orders on the edges of an equilateral triangle
      orders.Move.transform("t-#{orderRadius*0.86},-#{orderRadius/2}")
      orders.Support.transform("t#{orderRadius*0.86},-#{orderRadius/2}")
      orders.Hold.transform("t0,#{orderRadius}")

      g = snap.group(orders.Move, orders.Support, orders.Hold)

      g.transform("t-1000,1000").attr({ id: "orderGroup" })

      snap.select("#orders").append(g)

    return that

  return Map
)
