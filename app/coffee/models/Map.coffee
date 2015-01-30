define([
  'angular'
  'snap'
  'models/Province'
  'models/mapData'
  'util'
], (
  angular
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

  # Object that loads and populates the map
  # selector is a jQuery selector for the div where the map should be under
  Map = (initialScope, $q, selector, svgPath) ->

    that = {
      provinces: {} # map of province abbreviation to Province object
      loaded: false
      clickHandlers: {} # map of province abbreviation to current click handler (to be able to remove them)
      unitSVGs: {} # map of unit names to promises for snap fragments
    }

    for unitType in ["Army", "Fleet"]
      deferred = $q.defer()
      that.unitSVGs[unitType] = deferred.promise

      makeResolver = (unitType, deferred) ->
        (fragment) ->
          console.debug("resolve for #{unitType}")
          deferred.resolve(fragment)

      Snap.load("img/#{unitType}.svg", makeResolver(unitType, deferred))

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

      console.debug "Map loaded"
      initialScope.$apply ->
        that.loaded = true
    )

    # refresh nationalities and units on map
    that.refresh = (game) ->
      console.debug "Refreshing game", game.Phase.Ordinal

      # this?
      # deactivate any previously activated provinces
      for provinceName, province of that.provinces
        that.deactivateProvince(provinceName)

      # update SC ownership
      for provinceName, nation of game.Phase.SupplyCenters
        province = that.provinces[provinceName]

        if province?
          province.setNation(nation)

      # remove previous units
      units = that.snap.selectAll("#units > path")
      if units?
        units.remove()

      # insert new units
      for provinceName, unit of game.Phase.Units
        if provinceName.indexOf("/") > -1
          provinceName = cleanCoast(provinceName)

        unitPromise = that.unitSVGs[unit.Type]
        if unitPromise?
          # closure containing provinceName and unit
          makeInserter = (provinceName, unit) ->
            (unitSVG) ->
              that.insertUnit(provinceName, unit, unitSVG)

          unitPromise.then(makeInserter(provinceName, unit))
        else
          console.error "No unit promise for #{unit.Type}(#{provinceName})."

    that.bindOrders = (lieutenant) ->
      for orderType, orderSnap of this.orders
        orderSnap.unclick this.clickHandlers[orderType] if this.clickHandlers[orderType]?

        this.clickHandlers[orderType] = ((name) ->
          return ->
            lieutenant.fsm.handle 'chose.order', name
        )(orderType)

        orderSnap.click this.clickHandlers[orderType]

    that.insertUnit = (provinceName, unit, unitSVG) ->
      unitLayer = that.snap.select("svg #units")

      if unit.Type == "Army"
        unitFragmentOriginal = unitSVG.select("#body")
      else if unit.Type == "Fleet"
        unitFragmentOriginal = unitSVG.select("#hull")
      else
        console.warn "Unit type #{unit.Type} not recognized"

      # clone because appending removed the original
      unitFragment = unitFragmentOriginal.clone()

      if not unitFragment?
        console.warn "#{unit.Type} not found in fragment", provinceName
        return

      # put unit approximately on the province center
      unitBBox = unitFragment.getBBox()
      centerBBox = that.snap.select("##{provinceName}Center").getBBox()

      unitLayer.append(unitFragment)
      t = new Snap.Matrix().translate(centerBBox.cx - (unitBBox.width/2), centerBBox.cy - (unitBBox.height/2))
      unitFragment.attr({
        "fill": MapData.powers[unit.Nation].colour
        "stroke-width": "2px"
      })

      unitFragment.transform(t)

    that.activateProvince = (abbr, handler) ->
      that.addHoverHandlers(abbr)
      that.addClickHandler(abbr, handler)
      that.highlightProvince(abbr)

    that.deactivateProvince = (abbr) ->
      that.removeHoverHandlers(abbr)
      that.removeClickHandler(abbr)
      that.dehighlightProvince(abbr)

    that.findProvinceByAbbr = (abbr, callback) ->
      province = that.provinces[cleanCoast(abbr)]

      if province?
        callback(province)
      else
        console.warn "Cannot find province #{abbr}: it does not exist!"

    that.addHoverHandlers = (abbr) ->
      that.findProvinceByAbbr(abbr, (province) ->
        province.path.hover hoverIn, hoverOut
      )

    that.removeHoverHandlers = (abbr) ->
      that.findProvinceByAbbr(abbr, (province) ->
        province.path.unhover hoverIn, hoverOut
        hoverOut.call(province.path)
      )

    that.addClickHandler = (abbr, callback) ->
      that.findProvinceByAbbr(abbr, (province) ->
        that.clickHandlers[abbr] = (event) ->
          callback.bind(this)()

        province.path.click that.clickHandlers[abbr]
      )

    that.removeClickHandler = (abbr) ->
      that.findProvinceByAbbr(abbr, (province) ->
        province.path.unclick that.clickHandlers[abbr]
        delete that.clickHandlers[abbr]
      )

    that.highlightProvince = (abbr) ->
      that.findProvinceByAbbr(abbr, (province) -> province.addClass("highlight"))

    that.dehighlightProvince = (abbr) ->
      that.findProvinceByAbbr(abbr, (province) ->
        province.removeClass("highlight"))

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

    that.hideOrders = ->
      console.debug "Hiding orders"

      Snap.select("#orderGroup").transform("t-5000,-5000")
      for name, order of that.orders
        order.node.classList.remove("show")

    that.createOrders = (snap) ->
      orders = {}

      orderTypes = ["Move", "Support", "Hold", "Convoy", "Army", "Fleet", "Disband"]

      g = snap.group()

      for orderType in orderTypes
        c = snap.circle(0, 0, 35).attr
          fill: "rgb(236, 240, 241)",
          stroke: "#1f2c39",
          strokeWidth: 3

        text = snap.text(0, 0, orderType[0])
        text.attr({
            'font-size': 50
        })

        b = text.getBBox()

        c.attr
          cx: b.cx
          cy: b.cy

        orders[orderType] = snap.group(c, text).attr({
          id: "order-#{orderType}"
        })

        g.add(orders[orderType])

      g.transform("t-1000,1000").attr({ id: "orderGroup" })

      snap.select("#orders").append(g)

      that.orders = orders

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
