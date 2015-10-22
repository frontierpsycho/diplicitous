define([
  'models/Order'
  'lodash'
], (
  Order
  _
) ->
  'use strict'

  class OrderCollection
    constructor: (diplicityOrders) ->
      @orders = {}

      if diplicityOrders
        console.debug(diplicityOrders)
        for nation, nationOrders of diplicityOrders
          @convertOrders(nation, nationOrders)


    resolve: (resolutions) ->
      _.each(resolutions, (resolution, provinceAbbr) =>
        @orders[provinceAbbr]?.resolution = resolution
      )

    convertOrders: (nation, diplicity_orders) ->
      for own unit_area, diplicity_order of diplicity_orders
        @orders[unit_area] = Order(nation, unit_area, diplicity_order)

  class CurrentOrderCollection extends OrderCollection 
    constructor: (diplicityOrders, options, nation) ->
      super(diplicityOrders)
      @options = options
      @nation = nation
      @currentOrder = Order(@nation)

    storeOrder: ->
      console.debug "Storing order", @currentOrder
      @orders[@currentOrder.unit_area] = @currentOrder
      @currentOrder = Order(@nation)

    cancelOrder: ->
      @currentOrder = Order(@nation)

    deleteOrder: (order) ->
      if order.unit_area of @orders
        delete @orders[order.unit_area]
      else
        console.warn "Tried to delete order which wasn't there: #{order}"

    # calculate the next set of options the player has, based on what's already selected
    nextOptions: ->
      options = @options

      if @currentOrder.unit_area?
        options = options[@currentOrder.unit_area].Next

      if @currentOrder.type?
        options = options[@currentOrder.type]

        if @currentOrder.type != "Build"
          options = options.Next[@currentOrder.unit_area]

        options = options.Next

      if @currentOrder.src?
        options = options[@currentOrder.src]
          .Next

      _.keys(options)

  {
    OrderCollection: OrderCollection
    CurrentOrderCollection: CurrentOrderCollection
  }
)
