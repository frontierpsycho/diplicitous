define([
  'machina'
], (
  Machina
) ->
  'use strict'

  MovementFSM = ($scope, newLieutenant) ->
    return new Machina.Fsm({
      initialState: 'start'

      states:
        start:
          _onEnter: newLieutenant.onEnterWrapper(->
            $scope.$apply =>
              newLieutenant.fsm.handle("chose.unit", this.attr("id"))
          )

          'chose.unit': (abbr) ->
            console.debug "Chose unit in #{abbr}"
            newLieutenant.orders.currentOrder.unit_area = abbr

            newLieutenant.fsm.transition("order_type")

        # this state is special, since we need to add handlers to the order markers
        # instead of provinces, like the rest
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
          _onEnter: newLieutenant.onEnterWrapper(->
            console.debug this.attr("id")
            newLieutenant.fsm.handle("chose.src", this.attr("id"))
          )

          'chose.src': (src) ->
            console.debug "Chose source #{src}"
            $scope.$apply ->
              newLieutenant.orders.currentOrder.src = src
            this.transition("dst")

        dst:
          _onEnter: newLieutenant.onEnterWrapper(->
            newLieutenant.fsm.handle("chose.dst", this.attr("id"))
          )

          'chose.dst': (dst) ->
            console.debug "Chose destination #{dst}"
            $scope.$apply ->
              newLieutenant.orders.currentOrder.dst = dst
              newLieutenant.orders.storeOrder()
            this.transition("start")
    })

  MovementFSM
)

