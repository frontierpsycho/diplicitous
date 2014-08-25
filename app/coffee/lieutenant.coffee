define([
  'angular'
  'machina'
  'models/Player'
  'models/OrderCollection'
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
    newLieutenant =
      orders: null

      active: []
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

      onEnterWrapper: (onClickFunc) ->
        return ->
          newLieutenant.removeActiveHandlers()

          nextOptions = newLieutenant.orders.nextOptions()

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

        this.orders = OrderCollection(this.player.Options)
        this.orders.convertOrders($scope.game.Phase.Orders[this.player.Nation])
        _.each(this.orders.orders, (order) -> order.committed = true)

        switch type
          when 'Movement'
            console.debug "User: #{$scope.user.Email}"

            this.fsm = new Machina.Fsm({
              initialState: 'start'

              states:
                start:
                  _onEnter: this.onEnterWrapper(-> # this is newLieutenant
                    $scope.$apply =>
                      $scope.map.activateCoasts()
                      newLieutenant.fsm.handle("chose.unit", this.attr("id"))
                  )

                  'chose.unit': (abbr) ->
                    console.debug "Chose unit in #{abbr}"
                    newLieutenant.orders.currentOrder.unit_area = abbr

                    if newLieutenant.units[abbr].Type == "Army"
                      $scope.map.deactivateCoasts()

                    newLieutenant.fsm.transition("order_type")

                order_type:
                  _onEnter: ->
                    newLieutenant.removeActiveHandlers()

                    console.debug 'Entered order_type'

                    orderTypes = newLieutenant.orders.nextOptions()

                    $scope.map.activateOrders(newLieutenant.orders.currentOrder.unit_area, orderTypes)

                  'chose.order': (type) ->
                    console.debug "Chose order type #{type}"
                    $scope.$apply ->
                      newLieutenant.orders.currentOrder.type = type

                    switch type
                      when "Move"
                        this.transition("dst")
                      when "Support", "Convoy"
                        this.transition("src")
                      when "Hold"
                        that = this
                        $scope.$apply ->
                          newLieutenant.orders.storeOrder()
                          that.transition("start")

                src:
                  _onEnter: this.onEnterWrapper(->
                    console.debug this.attr("id")
                    newLieutenant.fsm.handle("chose.src", this.attr("id"))
                  )

                  'chose.src': (src) ->
                    console.debug "Chose source #{src}"
                    $scope.$apply ->
                      newLieutenant.orders.currentOrder.src = src
                    this.transition("dst")

                dst:
                  _onEnter: this.onEnterWrapper(->
                    newLieutenant.fsm.handle("chose.dst", this.attr("id"))
                  )

                  'chose.dst': (dst) ->
                    console.debug "Chose destination #{dst}"
                    $scope.$apply ->
                      newLieutenant.orders.currentOrder.dst = dst
                      newLieutenant.orders.storeOrder()
                    this.transition("start")

            })

        return newLieutenant

    return newLieutenant

  return Lieutenant
)
