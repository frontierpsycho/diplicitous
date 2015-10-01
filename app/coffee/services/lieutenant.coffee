define([
  'angular'
  'models/Player'
  'models/OrderCollection'
  'fsm/movement'
  'fsm/adjustment'
  'fsm/retreat'
  'underscore'
  'services/services'
], (
  angular
  Player
  OrderCollection
  MovementFSM
  AdjustmentFSM
  RetreatFSM
  _
) ->
  'use strict'

  # The Lieutenant awaits your orders, and relays them to your armies and fleets.
  angular.module('diplomacyServices')
    .service('Lieutenant', [
      '$rootScope'
      'MapService',
      'wsService',
      ($scope, MapService, ws) ->
        this.orders = null # OrderCollection
        this.active = []   # provinces that have event handlers
        this.game = null
        this.player = null

        this.activateProvinces = (provinces, handler) ->
          console.debug "Activating provinces:", provinces
          for province in provinces
            MapService.activateProvince(province, handler)
          this.active = provinces
        this.deactivateProvinces = ->
          console.debug "Deactivating provinces"
          for province in this.active
            MapService.deactivateProvince province
          MapService.hideOrders()
          this.active = []

        # Common onEnter functionality for FSM states
        # onClickFunc is ran when one of the active provinces is clicked
        # (with this set to the Snap.svg object)
        this.onEnterWrapper = (onClickFunc) ->
          that = this
          return ->
            # remove all province event handlers (hovers, clicks)
            that.deactivateProvinces()

            # determine the provinces/objects that should be active on this state
            nextOptions = that.orders.nextOptions()

            # make a list of options that are coastal
            coastOptions = _.chain(nextOptions)
              .filter((item) -> item.indexOf("/") != -1)
              .map((item) -> item.replace("/", "-"))
              .value()

            console.debug("Activate coasts:", coastOptions)

            MapService.activateCoasts(coastOptions)

            # add handlers to the current options
            that.activateProvinces nextOptions, onClickFunc

        this.sendOrders = ->
          that = this
          _.chain(this.orders.orders)
            .filter((order) -> (not order.sent))
            .each((order) ->
              ws.sendRPC(
                "SetOrder"
                {
                  "GameId": that.game.Id
                  "Order": order.toDiplicity()
                }
                ((iOrder) ->
                  ->
                    iOrder.sent = true
                )(order)
              )
              console.debug "Sent", order.toDiplicity()
            )

        this.commitOrders = ->
          that = this
          ws.sendRPC("Commit", { "PhaseId": this.game.Phase.Id }, ->
            that.player.Committed = true
          )

        this.uncommitOrders = ->
          that = this
          ws.sendRPC("Uncommit", { "PhaseId": this.game.Phase.Id }, ->
            that.player.Committed = false
          )

        this.deleteRemoteOrder = (order) ->
          that = this
          ws.sendRPC(
            "SetOrder"
            {
              "GameId": that.game.Id
              "Order": [ order.unit_area ]
            }
            ((iOrder) ->
              ->
                that.deleteOrder(iOrder)
            )(order)
          )

        this.cancelOrder = ->
          if this.orders?
            this.orders.cancelOrder()
          else
            console.warn("Tried to cancel when no orders object present")
          if this.fsm?
            this.fsm.transition("start")
          else
            console.warn("Tried to cancel when no fsm object present")

        this.deleteOrder = (order) ->
          if this.orders?
            this.orders.deleteOrder(order)
          else
            console.warn("Tried to delete when no orders object present")
          if this.fsm?
            this.fsm.handle("order.deleted")
          else
            console.warn("Tried to delete order with no fsm present")


        this.refresh = (game, user) ->
          this.deactivateProvinces()

          this.game = game
          this.player = Player(game.player(user))

          # read the orders we get from the backend
          this.orders = OrderCollection(this.player.Options, this.player.Nation)
          # and turn them into Order objects
          for nation, nationOrders of game.Phase.Orders
            this.orders.convertOrders(nation, nationOrders)

          if game.Phase.Resolved
            this.orders.resolve(game.Phase.Resolutions)

          # all orders coming from the backend on load are sent
          that = this
          _.each(this.orders.orders, (order) -> order.sent = true)

          # bind orders symbols on the map to this lieutenant
          MapService.bindOrders(this)

          if game.isCurrentPhase()
            switch game.Phase.Type
              when 'Movement'
                this.fsm = MovementFSM($scope, MapService, this)
              when 'Adjustment'
                this.fsm = AdjustmentFSM($scope, MapService, this)
              when 'Retreat'
                this.fsm = RetreatFSM($scope, MapService, this)

        return this
    ])
)
