define([
  'underscore'
], (
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
      committed: false
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

      that

    that.toDiplicity = ->
      _.without([
        soilCoast(that.unit_area)
        that.type
        soilCoast(that.src)
        soilCoast(that.dst)
      ], undefined)

    if unit_area? and diplicity_order?
      that.fromDiplicity(unit_area, diplicity_order)

    that
)
