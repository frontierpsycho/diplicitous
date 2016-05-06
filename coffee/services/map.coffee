define([
  'angular'
  'snap'
  'models/Province'
  'models/mapData'
  'drawing'
  'util'
  'services/viewBoxString'
  'lodash'
  'services/services'
], (
  angular
  Snap
  Province
  MapData
  Drawing
  Util
  ViewBoxString
  _
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

  angular.module('diplomacyServices')
    .service('MapService', ['$q', ($q) ->
      this.provinces = {} # map of province abbreviation to Province object
      this.orders = {} # map of order name to snap group
      this.loaded = false

      clickHandlers = {} # map of province abbreviation to current click handler (to be able to remove them)
      unitSVGs = {} # map of unit names to promises for snap fragments

      for unitType in ["Army", "Fleet"]
        deferred = $q.defer()
        unitSVGs[unitType] = deferred.promise

        makeUnitResolver = (unitType, deferred) ->
          (fragment) ->
            console.debug("Resolving promise for #{unitType}")
            deferred.resolve(fragment)

        Snap.load("img/#{unitType}.svg", makeUnitResolver(unitType, deferred))

      # refresh nationalities and units on map
      this.refresh = (game) ->
        console.debug "Refreshing game", game.Phase.Ordinal

        # deactivate any previously activated provinces
        for provinceName, province of this.provinces
          this.deactivateProvince(provinceName)

        # update SC ownership
        for provinceName, nation of game.Phase.SupplyCenters
          province = this.provinces[provinceName]

          if province?
            province.setNation(nation)

        # remove previous units
        units = this.snap.selectAll("#units > path")
        if units?
          units.remove()

        # insert new units
        for provinceName, unit of game.Phase.Units
          unitPromise = unitSVGs[unit.Type]
          if unitPromise?
            # closure containing provinceName and unit
            that = this
            makeInserter = (provinceName, unit) ->
              (unitSVG) ->
                that.insertUnit(provinceName, unit, unitSVG)

            unitPromise.then(makeInserter(provinceName, unit))
          else
            console.error "No unit promise for #{unit.Type}(#{provinceName})."

        # insert dislodged units
        for provinceName, unit of game.Phase.Dislodgeds
          unitPromise = unitSVGs[unit.Type]
          if unitPromise?
            # closure containing provinceName and unit
            that = this
            makeInserter = (provinceName, unit) ->
              (unitSVG) ->
                that.insertDislodgedUnit(provinceName, unit, unitSVG)

            unitPromise.then(makeInserter(provinceName, unit))
          else
            console.error "No unit promise for #{unit.Type}(#{provinceName})."

      this.bindOrders = (lieutenant) ->
        for orderType, orderSnap of this.orders
          orderSnap.unclick clickHandlers[orderType] if clickHandlers[orderType]?

          clickHandlers[orderType] = ((name) ->
            return ->
              lieutenant.fsm.handle 'chose.order', name
          )(orderType)

          orderSnap.click clickHandlers[orderType]

      this.insertUnit = (provinceName, unit, unitSVG, dislodged) ->
        unitLayer = this.snap.select(if dislodged then "svg #dislodged-units" else "svg #units")

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
        centerBBox = this.snap.select("##{provinceName}Center").getBBox()

        unitLayer.append(unitFragment)
        t = new Snap.Matrix().translate(centerBBox.cx - (unitBBox.width/2), centerBBox.cy - (unitBBox.height/2))
        unitFragment.attr({
          "fill": MapData.powers[unit.Nation].colour
          "stroke-width": "2px"
        })

        unitFragment.transform(t)

      this.insertDislodgedUnit = (provinceName, unit, unitSVG) ->
        this.insertUnit(provinceName, unit, unitSVG, true)

      this.activateProvince = (abbr, handler) ->
        this.addHoverHandlers(abbr)
        this.addClickHandler(abbr, handler)
        this.highlightProvince(abbr)

      this.deactivateProvince = (abbr) ->
        this.removeHoverHandlers(abbr)
        this.removeClickHandler(abbr)
        this.dehighlightProvince(abbr)

      this.findProvinceByAbbr = (abbr, callback) ->
        province = this.provinces[abbr]

        if province?
          callback(province)
        else
          console.warn "Cannot find province #{abbr}: it does not exist!"

      this.addHoverHandlers = (abbr) ->
        this.findProvinceByAbbr(abbr, (province) ->
          province.path.hover hoverIn, hoverOut
        )

      this.removeHoverHandlers = (abbr) ->
        this.findProvinceByAbbr(abbr, (province) ->
          province.path.unhover hoverIn, hoverOut
          hoverOut.call(province.path)
        )

      this.addClickHandler = (abbr, callback) ->
        this.findProvinceByAbbr(abbr, (province) ->
          clickHandlers[abbr] = (event) ->
            callback.bind(this)()

          province.path.click clickHandlers[abbr]
        )

      this.removeClickHandler = (abbr) ->
        this.findProvinceByAbbr(abbr, (province) ->
          province.path.unclick clickHandlers[abbr]
          delete clickHandlers[abbr]
        )

      this.highlightProvince = (abbr) ->
        this.findProvinceByAbbr(abbr, (province) -> province.addClass("highlight"))

      this.dehighlightProvince = (abbr) ->
        this.findProvinceByAbbr(abbr, (province) ->
          province.removeClass("highlight"))

      this.activateOrders = (abbr, orderTypes) ->
        console.debug "Activating orders"

        provinceCenter = Snap.select("##{abbr}Center").getBBox()

        that = this
        [validOrderTypes, invalidOrderTypes] = _.partition(orderTypes, (item) -> _.includes(_.keys(that.orders), item))

        console.debug orderTypes, validOrderTypes, invalidOrderTypes
        points = Util.placeOrdersCircular(validOrderTypes.length)

        for orderType in validOrderTypes
          point = points.pop()
          this.orders[orderType]
            .transform("t#{orderRadius * Math.cos(point)}, #{orderRadius * Math.sin(point)}")
            .node.classList.add("show")

        Snap.select("#orderGroup").transform("t#{provinceCenter.x},#{provinceCenter.y}")

      this.hideOrders = ->
        console.debug "Hiding orders"

        Snap.select("#orderGroup").transform("t-5000,-5000")
        for name, order of this.orders
          order.node.classList.remove("show")

      this.createOrders = ->
        orders = {}

        orderTypes = ["Move", "Support", "Hold", "Convoy", "Army", "Fleet", "Disband"]

        g = this.snap.group()

        for orderType in orderTypes
          c = this.snap.circle(0, 0, 35).attr
            fill: "rgb(236, 240, 241)",
            stroke: "#1f2c39",
            strokeWidth: 3

          text = this.snap.text(0, 0, orderType[0])
          text.attr({
              'font-size': 50
          })

          b = text.getBBox()

          c.attr
            cx: b.cx
            cy: b.cy

          orders[orderType] = this.snap.group(c, text).attr({
            id: "order-#{orderType}"
          })

          g.add(orders[orderType])

        g.transform("t-1000,1000").attr({ id: "orderGroup" })

        this.snap.select("#orders").append(g)

        this.orders = orders

      this.deactivateCoasts = ->
        this.activateCoasts()

      # activate the given coasts, deactivate all the rest
      this.activateCoasts = (coasts) ->
        that = this
        coasts = coasts || []
        _.each(this.provinces, (province, provinceName) ->
          if (province.isCoast())
            if (provinceName in coasts)
              province.activateCoast()
              console.debug("Activating coast #{province.abbr}, plus parent:", province.parent)
              that.highlightProvince(province.parent.abbr)
            else
              province.deactivateCoast()
        )

      this.scroll = (x, y) ->
        vb = new ViewBoxString(this.snap.node.getAttribute('viewBox'))
        vb.scroll(x, y)
        this.snap.node.setAttribute('viewBox', vb.toString())

      this.zoomPercent = (percent) ->
        vb = new ViewBoxString(this.snap.node.getAttribute('viewBox'))
        vb.zoomPercent(percent)
        this.snap.node.setAttribute('viewBox', vb.toString())

      this.setViewBox = (viewBoxString) ->
        this.snap.node.setAttribute('viewBox', viewBoxString)

      this.init = ->
        this.snap = Snap("#map svg")

        coasts = {}

        provinces = this.snap.selectAll("#provinces path")
        for province in provinces
          provinceName = province.attr("id")

          [landName, coastName] = tokenizeAbbr(provinceName)

          this.provinces[provinceName] = Province(provinceName, province)

          if coastName
            coasts[landName] ?= {}
            coasts[landName][coastName] = this.provinces[provinceName]

        for landName, coastSet of coasts
          this.provinces[landName].setCoasts(coastSet)

        this.createOrders()

        console.debug "Map loaded"
        this.loaded = true

      return this
    ])
)
