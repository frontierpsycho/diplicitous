define([
  'angular'
  'machina'
  'models/Player'
  'models/OrderCollection'
  'fsm/movement'
  'fsm/adjustment'
  'fsm/retreat'
  'underscore'
], (
  angular
  Machina
  Player
  OrderCollection
  MovementFSM
  AdjustmentFSM
  RetreatFSM
  _
) ->
  'use strict'

  ###*
  * The Lieutenant awaits your orders, and relays them to your armies and fleets.
  *###
  Lieutenant = ($scope, ws) ->
    newLieutenant =
      orders: null # OrderCollection
      active: []   # provinces that have event handlers

      activateProvinces: (provinces, handler) ->
        console.debug "Activating provinces"
        for province in provinces
          $scope.map.activateProvince(province, handler)
        this.active = provinces
      deactivateProvinces: ->
        console.debug "Deactivating provinces"
        for province in this.active
          $scope.map.deactivateProvince province
        $scope.map.hideOrders()
        this.active = []

      # Common onEnter functionality for FSM states
      # onClickFunc is ran when one of the active provinces is clicked
      # (with this set to the Snap.svg object)
      onEnterWrapper: (onClickFunc) ->
        return ->
          # remove all province event handlers (hovers, clicks)
          newLieutenant.deactivateProvinces()

          # determine the provinces/objects that should be active on this state
          nextOptions = newLieutenant.orders.nextOptions()

          # make a list of options that are coastal
          coastOptions = _.chain(nextOptions)
            .filter((item) -> item.indexOf("/") != -1)
            .map((item) -> item.replace("/", "-"))
            .value()

          console.debug("Activate coasts:", coastOptions)

          $scope.map.activateCoasts(coastOptions)

          # add handlers to the current options
          newLieutenant.activateProvinces nextOptions, onClickFunc

      sendOrders: ->
        _.chain(this.orders.orders)
          .filter((order) -> (not order.sent))
          .each((order) ->
            ws.sendRPC(
              "SetOrder"
              {
                "GameId": $scope.game.Id
                "Order": order.toDiplicity()
              }
              ((iOrder) ->
                ->
                  $scope.$apply ->
                    iOrder.sent = true
              )(order)
            )
            console.debug "Sent", order.toDiplicity()
          )

      commitOrders: ->
        ws.sendRPC("Commit", { "PhaseId": $scope.game.Phase.Id }, ->
          $scope.$apply ->
            newLieutenant.player.Committed = true
        )

      uncommitOrders: ->
        ws.sendRPC("Uncommit", { "PhaseId": $scope.game.Phase.Id }, ->
          $scope.$apply ->
            newLieutenant.player.Committed = false
        )

      deleteRemoteOrder: (order) ->
        ws.sendRPC(
          "SetOrder"
          {
            "GameId": $scope.game.Id
            "Order": [ order.unit_area ]
          }
          ((iOrder) ->
            ->
              $scope.lieutenant.deleteOrder(iOrder)
          )(order)
        )

      cancelOrder: ->
        if this.orders?
          this.orders.cancelOrder()
        else
          console.warn("Tried to cancel when no orders object present")
        if this.fsm?
          this.fsm.transition("start")
        else
          console.warn("Tried to cancel when no fsm object present")

      deleteOrder: (order) ->
        if this.orders?
          this.orders.deleteOrder(order)
        else
          console.warn("Tried to delete when no orders object present")
        if this.fsm?
          this.fsm.handle("order.deleted")
        else
          console.warn("Tried to delete order with no fsm present")

      init: (type) ->
        console.debug 'Initializing Lieutenant'

        unless $scope.user.Email?
          console.warn "There is no user"
          return this

        this.player = Player($scope.game.player($scope.user))

        this.units = $scope.game.Phase.Units

        # read the orders we get from the backend
        this.orders = OrderCollection(this.player.Options)
        # and turn them into Order objects
        this.orders.convertOrders($scope.game.Phase.Orders[this.player.Nation])

        # all orders coming from the backend on load are sent
        that = this
        _.each(this.orders.orders, (order) -> order.sent = true)

        switch type
          when 'Movement'
            newLieutenant.fsm = MovementFSM($scope, newLieutenant)
          when 'Adjustment'
            newLieutenant.fsm = AdjustmentFSM($scope, newLieutenant)
          when 'Retreat'
            newLieutenant.fsm = RetreatFSM($scope, newLieutenant)

        return newLieutenant

    return newLieutenant

  return Lieutenant
)
