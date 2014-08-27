define([
  'models/Order'
  'underscore'
], (
  Order
  _
) ->
  'use strict'

  OrderCollection = (options) ->
    that =
      orders: {}
      currentOrder: Order()
      options: options

    that.get = ->
      that.orders

    that.convertOrders = (diplicity_orders) ->
      for own unit_area, diplicity_order of diplicity_orders
        that.orders[unit_area] = Order(unit_area, diplicity_order)

    that.storeOrder = ->
      console.debug "Storing order", that.currentOrder
      that.orders[that.currentOrder.unit_area] = that.currentOrder
      that.currentOrder = Order()

      console.debug "Orders:", that.orders

    that.cancelOrder = ->
      that.currentOrder = Order()

    # calculate the next set of options the player has, based on what's already selected
    that.nextOptions = ->
      options = that.options

      if that.currentOrder.unit_area?
        options = options[that.currentOrder.unit_area].Next

      if that.currentOrder.type?
        options = options[that.currentOrder.type]
          .Next[that.currentOrder.unit_area]
          .Next

      if that.currentOrder.src?
        options = options[that.currentOrder.src]
          .Next

      _.keys(options)

    that
)
