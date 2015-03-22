define([
  'drawing'
  'underscore'
], (
  Drawing
  _
) ->
  'use strict'

  cleanCoast = (abbr) ->
    if abbr?
      abbr.replace("/", "-")
    else
      abbr

  soilCoast = (abbr) ->
    if abbr?
      abbr.replace("-", "/")
    else
      abbr

  Order = (unit_area, diplicity_order) ->
    that = {
      sent: false
    }

    that.fromDiplicity = (unit_area, diplicity_order) ->
      if (not diplicity_order?) or _.isEmpty(diplicity_order) or (not diplicity_order[0]?)
        return that

      that.unit_area = cleanCoast(unit_area)
      that.type = diplicity_order[0]
      switch that.type
        when 'Move'
          that.dst = cleanCoast(diplicity_order[1])
        when 'Support', 'Convoy'
          that.src = cleanCoast(diplicity_order[1])
          that.dst = cleanCoast(diplicity_order[2])
        when 'Build'
          that.unit_type = diplicity_order[1]

      that

    that.toDiplicity = ->
      _.without([
        soilCoast(that.unit_area)
        that.type
        that.unit_type
        soilCoast(that.src)
        soilCoast(that.dst)
      ], undefined)

    that.draw = ->
      s = Snap("#map svg")
      if @type == "Move"
        ABBox = s.select("##{@unit_area}Center").getBBox()
        BBBox = s.select("##{@dst}Center").getBBox()

        pointA = new Drawing.Point(ABBox.cx, ABBox.cy)
        pointB = new Drawing.Point(BBBox.cx, BBBox.cy)
        path = s.path(Drawing.arrowPath(pointA, pointB)).attr({
          fill: "#32CD32"
          "fill-opacity": "0.8"
          stroke: "#2E8B57"
          "stroke-width": "2px"
          "stroke-opacity": "0.8"
        })
        s.select("#orderMarkings").append(path)

    that.arrowPath = ->
      s = Snap("#map svg")
      ABBox = s.select("##{@unit_area}Center").getBBox()
      BBBox = s.select("##{@dst}Center").getBBox()

      pointA = new Drawing.Point(ABBox.cx, ABBox.cy)
      pointB = new Drawing.Point(BBBox.cx, BBBox.cy)

      path = Drawing.arrowPath(pointA, pointB).join(" ")
      path

    if unit_area? and diplicity_order?
      that.fromDiplicity(unit_area, diplicity_order)


    that
)
