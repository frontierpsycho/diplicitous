define([
  'objects/Order'
], (
  Order
) ->
  'use strict'

  OrderCollection = ->
    that =
      orders: {}
      #options: options
      #currentOrder: {}

    that.convertOrders = (diplicity_orders) ->
      for own unit_area, diplicity_order of diplicity_orders
        that.orders[unit_area] = Order().fromDiplicity(unit_area, diplicity_order)

    that.storeOrder = (order) ->
      that.orders[order.unit_area] = order

    that.get = ->
      that.orders

    that
)
