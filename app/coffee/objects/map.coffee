define([
  'snap'
  'objects/Province'
  'objects/mapData'
], (
  Snap
  Province
  MapData
) ->
  'use strict'

  hoverIn = (event) ->
    this.node.classList.add("active")

  hoverOut = (event) ->
    this.node.classList.remove("active")

  abbrWithoutCoast = (abbr) ->
    abbr.split("-")[0]

  cleanCoast = (abbr) ->
    abbr.replace("/", "-")

  Map = ($scope, selector, svgPath) ->

    that = {
      provinces: {}
      loaded: false
      clickHandlers: {}
    }

    that.snap = Snap(selector)
    Snap.load(svgPath, (data) ->
      data.select("#provinces").attr
        style: ""
      provinces = data.selectAll("#provinces path")
      for province in provinces
        provinceName = cleanCoast(province.attr("id"))

        that.provinces[provinceName] = Province(provinceName, province)

      that.snap.append(data)

      s = Snap("#{selector} svg")

      that.createOrders(s)

      console.debug "Map loaded"
      $scope.$apply ->
        that.loaded = true

      deregisterWatch = $scope.$watch('game', ->
        console.debug "Game loaded!", $scope.game.Id

        for provinceName, unit of $scope.game.Phase.Units
          coast = false
          if provinceName.indexOf("/") > -1
            coast = true
            provinceName = cleanCoast(provinceName)
          province = that.provinces[provinceName]
          if province?
            if coast
              that.provinces[abbrWithoutCoast(provinceName)].addClass(unit.Nation)
            else
              province.addClass(unit.Nation)
          else
            console.error "Province does not exist: ", provinceName

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

    that.hoverProvince = (abbr) ->
      province = that.provinces[abbr]

      if province?
        province.path.hover hoverIn, hoverOut
      else
        console.warn "Cannot add hover handlers to province #{abbr}: it does not exist!"

    that.unhoverProvince = (abbr) ->
      province = that.provinces[abbr]

      if province?
        province.path.unhover hoverIn, hoverOut
        hoverOut.call(province.path)
      else
        console.warn "Cannot remove hover handlers to province #{abbr}: it does not exist!"

    that.clickProvince = (abbr, callback) ->
      province = that.provinces[abbr]

      if province?
        that.clickHandlers[abbr] = (event) ->
          callback.bind(this)()

        province.path.click that.clickHandlers[abbr]
      else
        console.warn "Cannot add click handler to province #{abbr}: it does not exist!"

    that.unclickProvince = (abbr) ->
      province = that.provinces[abbr]

      if province?
        province.path.unclick that.clickHandlers[abbr]
        delete that.clickHandlers[abbr]

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

    that.deactivateCoasts = ->
      _.each(that.provinces, (province, provinceName) ->
        if (provinceName.indexOf("-") > -1)
          province.addClass("armySelected")
      )

    that.activateCoasts = ->
      _.each(that.provinces, (province, provinceName) ->
        if (provinceName.indexOf("-") > -1)
          province.removeClass("armySelected")
      )

    return that

  return Map
)
