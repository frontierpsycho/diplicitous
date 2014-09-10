define([
  'snap'
  'models/Province'
  'models/mapData'
  'util'
], (
  Snap
  Province
  MapData
  Util
) ->
  'use strict'

  # radius of the circle orders form around the selected unit
  orderRadius = 100

  # standard handlers for hovering in and out of provinces
  hoverIn = (event) ->
    this.node.classList.add("active")

  hoverOut = (event) ->
    this.node.classList.remove("active")

  # separates coast from main province in an abbreviation
  # example: spa-sc -> [spa, sc]
  tokenizeAbbr = (abbr) ->
    abbr.split("-")

  # diplicity coasts have slashes, which is invalid
  # this cleans them up (turns them into dashes)
  cleanCoast = (abbr) ->
    abbr.replace("/", "-")

  # returns a function that inserts unit into province called provinceName
  insertUnit = (provinceName, unit, snap) ->
    unitLayer = snap.select("svg #units")

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

  # Object that loads and populates the map
  # selector is a jQuery selector for the div where the map should be under
  Map = ($scope, selector, svgPath) ->

    that = {
      provinces: {} # map of province abbreviation to Province object
      loaded: false
      clickHandlers: {} # map of province abbreviation to current click handler (to be able to remove them)
    }

    that.snap = Snap(selector)
    Snap.load(svgPath, (data) ->
      coasts = {}

      provinces = data.selectAll("#provinces path")
      for province in provinces
        provinceName = cleanCoast(province.attr("id"))

        [landName, coastName] = tokenizeAbbr(provinceName)

        that.provinces[provinceName] = Province(provinceName, province)

        if coastName
          coasts[landName] ?= {}
          coasts[landName][coastName] = that.provinces[provinceName]

      for landName, coastSet of coasts
        that.provinces[landName].setCoasts(coastSet)

      console.debug("Coasts", coasts)

      that.snap.append(data)

      s = Snap("#{selector} svg")

      that.createOrders(s)
      that.createBuildOptions(s)

      console.debug "Map loaded"
      $scope.$apply ->
        that.loaded = true
    )

    that.refresh = (game) ->
      for provinceName, nation of game.Phase.SupplyCenters
        province = that.provinces[provinceName]
        if province?
          province.setNation(nation)

      for provinceName, unit of game.Phase.Units
        if provinceName.indexOf("/") > -1
          provinceName = cleanCoast(provinceName)

        # TODO don't make a new request for each unit
        Snap.load("img/#{unit.Type}.svg", insertUnit(provinceName, unit, that.snap))

    that.hoverProvince = (abbr) ->
      province = that.provinces[cleanCoast(abbr)]

      if province?
        province.path.hover hoverIn, hoverOut
      else
        console.warn "Cannot add hover handlers to province #{abbr}: it does not exist!"

    that.unhoverProvince = (abbr) ->
      province = that.provinces[cleanCoast(abbr)]

      if province?
        province.path.unhover hoverIn, hoverOut
        hoverOut.call(province.path)
      else
        console.warn "Cannot remove hover handlers to province #{abbr}: it does not exist!"

    that.clickProvince = (abbr, callback) ->
      province = that.provinces[cleanCoast(abbr)]

      if province?
        that.clickHandlers[abbr] = (event) ->
          callback.bind(this)()

        province.path.click that.clickHandlers[abbr]
      else
        console.warn "Cannot add click handler to province #{abbr}: it does not exist!"

    that.unclickProvince = (abbr) ->
      province = that.provinces[cleanCoast(abbr)]

      if province?
        province.path.unclick that.clickHandlers[abbr]
        delete that.clickHandlers[abbr]

    that.activateOrders = (abbr, orderTypes) ->
      console.debug "Activating orders"

      provinceCenter = Snap.select("##{abbr}Center").getBBox()

      [validOrderTypes, invalidOrderTypes] = _.partition(orderTypes, (item) -> _.contains(_.keys(that.orders), item))

      console.debug orderTypes, validOrderTypes, invalidOrderTypes
      points = Util.placeOrdersCircular(validOrderTypes.length)

      for orderType in validOrderTypes
        point = points.pop()
        that.orders[orderType]
          .transform("t#{orderRadius * Math.cos(point)}, #{orderRadius * Math.sin(point)}")
          .node.classList.add("show")

      Snap.select("#orderGroup").transform("t#{provinceCenter.x},#{provinceCenter.y}")

    that.activateBuildOptions = (abbr) ->
      console.debug "Activating build orders"

      provinceCenter = Snap.select("##{abbr}Center").getBBox()

      points = Util.placeOrdersCircular(2) # Army and Fleet

      for buildOption in ["Army", "Fleet"]
        point = points.pop()
        that.buildOptions[buildOption]
          .transform("t#{orderRadius * Math.cos(point)}, #{orderRadius * Math.sin(point)}")
          .node.classList.add("show")

      Snap.select("#buildOptionGroup").transform("t#{provinceCenter.x},#{provinceCenter.y}")

    that.hideOrders = ->
      console.debug "Hiding orders"

      Snap.select("#orderGroup").transform("t-5000,-5000")
      for name, order of that.orders
        order.node.classList.remove("show")

    that.hideBuildOptions = ->
      console.debug "Hiding build orders"

      Snap.select("#buildOptionGroup").transform("t-5000,-5000")
      for name, order of that.orders
        order.node.classList.remove("show")

    that.createOrders = (snap) ->
      orders = {}

      for orderName in ["Move", "Support", "Hold", "Convoy"]
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

      g = snap.group(orders.Move, orders.Support, orders.Hold, orders.Convoy)

      g.transform("t-1000,1000").attr({ id: "orderGroup" })

      snap.select("#orders").append(g)

      that.orders = orders

    that.createBuildOptions = (snap) ->
      buildOptions = {}

      for buildOptionName in ["Army", "Fleet"]
        c = snap.circle(0, 0, 35).attr
          fill: "rgb(236, 240, 241)",
          stroke: "#1f2c39",
          strokeWidth: 3

        text = snap.text(0, 0, buildOptionName[0])
        text.attr({
            'font-size': 50
        })

        b = text.getBBox()

        c.attr
          cx: b.cx
          cy: b.cy

        buildOptions[buildOptionName] = snap.group(c, text).attr({
          id: "build-option-#{buildOptionName}"
        })

        buildOptions[buildOptionName].click ((name) ->
          return ->
            $scope.lieutenant.fsm.handle 'chose.unit', name
        )(buildOptionName)

      g = snap.group(buildOptions.Army, buildOptions.Fleet)

      g.transform("t-1000,1000").attr({ id: "buildOptionGroup" })

      snap.select("#orders").append(g)

      that.buildOptions = buildOptions

    that.deactivateCoasts = ->
      this.activateCoasts()

    # activate the given coasts, deactivate all the rest
    that.activateCoasts = (coasts) ->
      coasts = coasts || []
      _.each(that.provinces, (province, provinceName) ->
        if (province.isCoast())
          if (provinceName in coasts)
            province.activateCoast()
          else
            province.deactivateCoast()
      )

    return that

  return Map
)
