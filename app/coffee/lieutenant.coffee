define([
  'angular'
  'machina'
  'objects/Player'
], (
  angular
  Machina
  Player
) ->
  'use strict'

  Lieutenant = ($scope) ->
    that =
      orders: {}
      currentOrder: {}

      storeOrder: ->
        console.debug "Storing order", that.currentOrder
        that.orders[that.currentOrder.unit_area] = that.currentOrder
        that.currentOrder = {}

        console.debug "Orders:", that.orders

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
                      that.currentOrder.unit_area = abbr
                    that.fsm.transition("order_type")

                order_type:
                  _onEnter: that.onEnterWrapper(->
                    console.debug 'Entered order_type'

                    order_types = _.keys(
                      that.player.Options[that.currentOrder.unit_area].Next)

                    select = $("<select></select>")
                    $("#orders").append(select)

                    _.each(order_types, (type) ->
                      select.append("<option>#{type}</option>")
                    )

                    select.change ->
                      that.fsm.handle("chose.order", $(this).find("option:selected").val())
                      select.remove()

                  )

                  'chose.order': (type) ->
                    console.debug "Chose order type #{type}"
                    $scope.$apply ->
                      that.currentOrder.type = type

                    switch type
                      when "Move"
                        that.fsm.transition("dst")
                      when "Support"
                        that.fsm.transition("src")

                src:
                  _onEnter: that.onEnterWrapper(->
                    console.debug 'Entered src'
                    srcs = _.keys(
                      that.player
                        .Options[that.currentOrder.unit_area]
                        .Next[that.currentOrder.type]
                        .Next[that.currentOrder.unit_area]
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
                      that.currentOrder.src = src
                    that.fsm.transition("dst")

                dst:
                  _onEnter: that.onEnterWrapper(->
                    console.debug 'Entered dst'

                    dsts = _.keys(
                      that.player
                        .Options[that.currentOrder.unit_area]
                        .Next[that.currentOrder.type]
                        .Next[that.currentOrder.unit_area]
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
                      that.currentOrder.dst = dst
                      that.storeOrder()
                    that.fsm.transition("start")

            })

        return that

    return that

  return Lieutenant
)
