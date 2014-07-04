define([
  'angular'
  'machina'
  'objects/Player'
  'objects/OrderCollection'
  'underscore'
], (
  angular
  Machina
  Player
  OrderCollection
  _
) ->
  'use strict'

  Lieutenant = ($scope) ->
    that =
      orders: null

      active: []
      addActiveHandlers: (hoverlist, handler) ->
        console.debug "Adding active handlers"
        for province in hoverlist
          $scope.map.hoverProvince province
          $scope.map.clickProvince(province, handler)
        that.active = hoverlist
      removeActiveHandlers: ->
        console.debug "Removing active handlers"
        for province in that.active
          $scope.map.unhoverProvince province
          $scope.map.unclickProvince province
        $scope.map.hideOrders()
        that.active = []

      onEnterWrapper: (onClickFunc) ->
        return ->
          that.removeActiveHandlers()

          nextOptions = that.orders.nextOptions()

          that.addActiveHandlers nextOptions, onClickFunc

      cancelOrder: ->
        if that.orders?
          that.orders.cancelOrder()
        else
          console.warn("Tried to cancel when no orders object present")
        if that.fsm?
          that.fsm.transition("start")
        else
          console.warn("Tried to cancel when no fsm object present")

      init: (type) ->
        console.debug 'Initializing Lieutenant'

        unless $scope.user.Email?
          console.warn "There is no user"
          return that

        that.player = Player($scope.game.player($scope.user))
        console.debug "Player:", that.player

        that.units = $scope.game.Phase.Units
        console.debug(that.units)

        that.orders = OrderCollection(that.player.Options)
        that.orders.convertOrders($scope.game.Phase.Orders[that.player.Nation])
        _.each(that.orders.orders, (order) -> order.committed = true)

        switch type
          when 'Movement'
            console.debug "User: #{$scope.user.Email}"

            that.fsm = new Machina.Fsm({
              initialState: 'start'

              states:
                start:
                  _onEnter: that.onEnterWrapper(->
                    $scope.$apply =>
                      $scope.map.activateCoasts()
                      that.fsm.handle("chose.unit", this.attr("id"))
                  )

                  'chose.unit': (abbr) ->
                    console.debug "Chose unit in #{abbr}"
                    that.orders.currentOrder.unit_area = abbr

                    if that.units[abbr].Type == "Army"
                      $scope.map.deactivateCoasts()

                    that.fsm.transition("order_type")

                order_type:
                  _onEnter: ->
                    that.removeActiveHandlers()

                    console.debug 'Entered order_type'

                    order_types = that.orders.nextOptions()

                    $scope.map.activateOrders(that.orders.currentOrder.unit_area)

                  'chose.order': (type) ->
                    console.debug "Chose order type #{type}"
                    $scope.$apply ->
                      that.orders.currentOrder.type = type

                    switch type
                      when "Move"
                        that.fsm.transition("dst")
                      when "Support"
                        that.fsm.transition("src")
                      when "Hold"
                        $scope.$apply ->
                          that.orders.storeOrder()
                          that.fsm.transition("start")


                src:
                  _onEnter: that.onEnterWrapper(->
                    console.debug this.attr("id")
                    that.fsm.handle("chose.src", this.attr("id"))
                  )

                  'chose.src': (src) ->
                    console.debug "Chose source #{src}"
                    $scope.$apply ->
                      that.orders.currentOrder.src = src
                    that.fsm.transition("dst")

                dst:
                  _onEnter: that.onEnterWrapper(->
                    that.fsm.handle("chose.dst", this.attr("id"))
                  )

                  'chose.dst': (dst) ->
                    console.debug "Chose destination #{dst}"
                    $scope.$apply ->
                      that.orders.currentOrder.dst = dst
                      that.orders.storeOrder()
                    that.fsm.transition("start")

            })

        return that

    return that

  return Lieutenant
)
