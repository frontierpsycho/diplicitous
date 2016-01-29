define([
  'drawing'
  'lodash'
], (
  Drawing
  _
) ->
  'use strict'

  Order = (nation, unit_area, diplicity_order) ->
    that = {
      sent: false
      nation: nation
      resolution: ""
    }

    that.fromDiplicity = (unit_area, diplicity_order) ->
      if (not diplicity_order?) or _.isEmpty(diplicity_order) or (not diplicity_order[0]?)
        return that

      that.unit_area = unit_area
      that.type = diplicity_order[0]
      switch that.type
        when 'Move'
          that.dst = diplicity_order[1]
        when 'Support', 'Convoy'
          that.src = diplicity_order[1]
          that.dst = diplicity_order[2]
        when 'Build'
          that.unit_type = diplicity_order[1]

      that

    that.toDiplicity = ->
      _.without([
        that.unit_area
        that.type
        that.unit_type
        that.src
        that.dst
      ], undefined)

    that.draw = ->
      s = Snap("#map svg")
      switch @type
        when "Move"
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
        when "Support"
          ABBox = s.select("##{@unit_area}Center").getBBox()
          BBBox = s.select("##{@src}Center").getBBox()

          pointA = new Drawing.Point(ABBox.cx, ABBox.cy)
          pointB = new Drawing.Point(BBBox.cx, BBBox.cy)
          path = s.path(Drawing.arrowPath(pointA, pointB)).attr({
            fill: "#3280CD"
            "fill-opacity": "0.8"
            stroke: "#2E4F8B"
            "stroke-width": "2px"
            "stroke-opacity": "0.8"
          })
          s.select("#orderMarkings").append(path)

    that.arrowPath = ->
      s = Snap("#map svg")
      switch @type
        when "Move"
          ABBox = s.select("##{@unit_area}Center").getBBox()
          BBBox = s.select("##{@dst}Center").getBBox()

          pointA = new Drawing.Point(ABBox.cx, ABBox.cy)
          pointB = new Drawing.Point(BBBox.cx, BBBox.cy)

          Drawing.arrowPath(pointA, pointB).join(" ")
        when "Support"
          ABBox = s.select("##{@unit_area}Center").getBBox()
          BBBox = s.select("##{@src}Center").getBBox()

          pointA = new Drawing.Point(ABBox.cx, ABBox.cy)
          pointB = new Drawing.Point(BBBox.cx, BBBox.cy)

          Drawing.arrowPath(pointA, pointB).join(" ")
        when "Convoy"
          ABBox = s.select("##{@unit_area}Center").getBBox()
          BBBox = s.select("##{@src}Center").getBBox()

          pointA = new Drawing.Point(ABBox.cx, ABBox.cy)
          pointB = new Drawing.Point(BBBox.cx, BBBox.cy)

          Drawing.arrowPath(pointA, pointB).join(" ")

    if unit_area? and diplicity_order?
      that.fromDiplicity(unit_area, diplicity_order)

    that
)
