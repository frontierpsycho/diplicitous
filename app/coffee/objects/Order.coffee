define([
], (
) ->
  'use strict'

  Order = (unit_area, diplicity_order) ->
    that = {}

    that.fromDiplicity = (unit_area, diplicity_order) ->
      that.unit_area = unit_area
      that.type = diplicity_order[0]
      switch that.type
        when 'Move'
          that.dst = diplicity_order[1]
        when 'Support'
          that.src = diplicity_order[1]
          that.dst = diplicity_order[2]

      that

    if unit_area? and diplicity_order?
      that.fromDiplicity(unit_area, diplicity_order)

    that
)
