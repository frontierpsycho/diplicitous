define([
  'objects/Order'
], (
  Order
) ->
  'use strict'

  OrderCollection = ->
    that =
      orders: {}
      currentOrder: {}
      #options: options

    that.convertOrders = (diplicity_orders) ->
      for own unit_area, diplicity_order of diplicity_orders
        that.orders[unit_area] = Order().fromDiplicity(unit_area, diplicity_order)

    that.storeOrder = ->
      console.debug "Storing order", that.currentOrder
      that.orders[that.currentOrder.unit_area] = that.currentOrder
      that.currentOrder = {}

      console.debug "Orders:", that.orders

    that.get = ->
      that.orders

    that
)
