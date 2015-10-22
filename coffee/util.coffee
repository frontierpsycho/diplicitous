define ->
  'use strict'

  radiansInCircle = 2 * Math.PI
  offset = Math.PI / 2

  return {
    placeOrdersCircular: (numberOfOrders) ->
      arcLength = radiansInCircle / numberOfOrders

      _.map(_.range(0, radiansInCircle, arcLength), (item) -> item + offset)
  }
