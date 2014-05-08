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
      orders: OrderCollection()

      active: []
      addActiveHandlers: (hoverlist, handler) ->
        for province in hoverlist
          $scope.map.hoverProvince province
          $scope.map.clickProvince(province, handler)
        that.active = hoverlist
      removeActiveHandlers: ->
        for province in that.active
          $scope.map.unhoverProvince province
        that.active = []

      onEnterWrapper: (func) ->
        return ->
          that.removeActiveHandlers()
          func()

      init: (type) ->
        console.debug 'Initializing Lieutenant'

        unless $scope.user.Email?
          console.warn "There is no user"
          return that

        that.player = Player($scope.game.player($scope.user))
        console.debug "Player:", that.player

        that.orders.convertOrders($scope.game.Phase.Orders[that.player.Nation])

        switch type
          when 'Movement'
            console.debug "User: #{$scope.user.Email}"

            that.fsm = new Machina.Fsm({
              initialState: 'start'

              states:
                start:
                  _onEnter: that.onEnterWrapper(->
                    console.debug 'Entered start'

                    units = _.keys(that.player.Options)

                    that.addActiveHandlers(units, ->
                      that.fsm.handle("chose.unit", this.attr("id"))
                    )
                  )

                  'chose.unit': (abbr) ->
                    console.debug "Chose unit in #{abbr}"
                    $scope.$apply ->
                      that.orders.currentOrder.unit_area = abbr

                    that.fsm.transition("order_type")

                order_type:
                  _onEnter: that.onEnterWrapper(->
                    console.debug 'Entered order_type'

                    order_types = _.keys(
                      that.player.Options[that.orders.currentOrder.unit_area].Next)

                    select = $("<select></select>")
                    $("#current-order").append(select)

                    _.each(order_types, (type) ->
                      select.append("<option>#{type}</option>")
                    )

                    select.get(0).selectedIndex = -1

                    select.change ->
                      that.fsm.handle("chose.order", $(this).find("option:selected").val())
                      select.remove()

                  )

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
                    console.debug 'Entered src'
                    srcs = _.keys(
                      that.player
                        .Options[that.orders.currentOrder.unit_area]
                        .Next[that.orders.currentOrder.type]
                        .Next[that.orders.currentOrder.unit_area]
                        .Next
                    )

                    that.addActiveHandlers(srcs, ->
                      console.debug this.attr("id")
                      that.fsm.handle("chose.src", this.attr("id"))
                    )
                  )

                  'chose.src': (src) ->
                    console.debug "Chose source #{src}"
                    $scope.$apply ->
                      that.orders.currentOrder.src = src
                    that.fsm.transition("dst")

                dst:
                  _onEnter: that.onEnterWrapper(->
                    console.debug 'Entered dst'

                    dsts = _.keys(
                      that.player
                        .Options[that.orders.currentOrder.unit_area]
                        .Next[that.orders.currentOrder.type]
                        .Next[that.orders.currentOrder.unit_area]
                        .Next
                    )
                    console.debug dsts

                    that.addActiveHandlers(dsts, ->
                      console.debug this.attr("id")
                      that.fsm.handle("chose.dst", this.attr("id"))
                    )
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
