define([
  'angular'
  'machina'
  'models/Player'
  'models/OrderCollection'
  'fsm/movement'
  'underscore'
], (
  angular
  Machina
  Player
  OrderCollection
  MovementFSM
  _
) ->
  'use strict'

  ###*
  * The Lieutenant awaits your orders, and relays them to your armies and fleets.
  *###
  Lieutenant = ($scope) ->
    newLieutenant =
      orders: null # OrderCollection
      active: []   # provinces that have event handlers

      addActiveHandlers: (hoverlist, handler) ->
        console.debug "Adding active handlers"
        for province in hoverlist
          $scope.map.hoverProvince province
          $scope.map.clickProvince(province, handler)
        this.active = hoverlist
      removeActiveHandlers: ->
        console.debug "Removing active handlers"
        for province in this.active
          $scope.map.unhoverProvince province
          $scope.map.unclickProvince province
        $scope.map.hideOrders()
        this.active = []

      # Common onEnter functionality for FSM states
      # onClickFunc is ran when one of the active provinces is clicked
      # (with this set to the Snap.svg object)
      onEnterWrapper: (onClickFunc) ->
        return ->
          # remove all province event handlers (hovers, clicks)
          newLieutenant.removeActiveHandlers()

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
          newLieutenant.addActiveHandlers nextOptions, onClickFunc

      cancelOrder: ->
        if this.orders?
          this.orders.cancelOrder()
        else
          console.warn("Tried to cancel when no orders object present")
        if this.fsm?
          this.fsm.transition("start")
        else
          console.warn("Tried to cancel when no fsm object present")

      init: (type) ->
        console.debug 'Initializing Lieutenant'

        unless $scope.user.Email?
          console.warn "There is no user"
          return this

        this.player = Player($scope.game.player($scope.user))
        console.debug "Player:", this.player

        this.units = $scope.game.Phase.Units
        console.debug(this.units)

        # read the orders we get from the backend
        this.orders = OrderCollection(this.player.Options)
        # and turn them into Order objects
        this.orders.convertOrders($scope.game.Phase.Orders[this.player.Nation])

        # all orders coming from the backen on load are committed
        _.each(this.orders.orders, (order) -> order.committed = true)

        switch type
          when 'Movement'
            console.debug "User: #{$scope.user.Email}"

            newLieutenant.fsm = MovementFSM($scope, newLieutenant)

        return newLieutenant

    return newLieutenant

  return Lieutenant
)
