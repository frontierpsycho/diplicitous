define([
  'models/Order'
  'lodash'
], (
  Order
  _
) ->
  'use strict'

  OrderCollection = (options, nation) ->
    that =
      orders: {}
      currentOrder: Order(nation)
      options: options
      nation: nation

    that.get = ->
      that.orders

    that.convertOrders = (nation, diplicity_orders) ->
      for own unit_area, diplicity_order of diplicity_orders
        that.orders[unit_area] = Order(nation, unit_area, diplicity_order)

    that.storeOrder = ->
      console.debug "Storing order", that.currentOrder
      that.orders[that.currentOrder.unit_area] = that.currentOrder
      that.currentOrder = Order(that.nation)

      console.debug "Orders:", that.orders

    that.cancelOrder = ->
      that.currentOrder = Order(that.nation)

    that.deleteOrder = (order) ->
      if order.unit_area of that.orders
        delete that.orders[order.unit_area]
      else
        console.warn "Tried to delete order which wasn't there: #{order}"

    # calculate the next set of options the player has, based on what's already selected
    that.nextOptions = ->
      options = that.options

      if that.currentOrder.unit_area?
        options = options[that.currentOrder.unit_area].Next

      if that.currentOrder.type?
        options = options[that.currentOrder.type]

        if that.currentOrder.type != "Build"
          options = options.Next[that.currentOrder.unit_area]

        options = options.Next

      if that.currentOrder.src?
        options = options[that.currentOrder.src]
          .Next

      _.keys(options)

    that.resolve = (resolutions) ->
      _.each(resolutions, (resolution, provinceAbbr) ->
        that.orders[provinceAbbr]?.resolution = resolution
      )

    that
)
