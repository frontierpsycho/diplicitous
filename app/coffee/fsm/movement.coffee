define([
  'machina'
], (
  Machina
) ->
  'use strict'

  MovementFSM = ($scope, MapService, lieutenant) ->
    return new Machina.Fsm({
      initialState: 'start'

      states:
        start:
          _onEnter: lieutenant.onEnterWrapper(->
            $scope.$apply =>
              lieutenant.fsm.handle("chose.unit", this.attr("id"))
          )

          'chose.unit': (abbr) ->
            console.debug "Chose unit in #{abbr}"
            lieutenant.orders.currentOrder.unit_area = abbr

            lieutenant.fsm.transition("order_type")

        # this state is special, since we need to add handlers to the order markers
        # instead of provinces, like the rest
        order_type:
          _onEnter: ->
            lieutenant.deactivateProvinces()

            console.debug 'Entered order_type'

            orderTypes = lieutenant.orders.nextOptions()

            MapService.activateOrders(lieutenant.orders.currentOrder.unit_area, orderTypes, lieutenant)

          'chose.order': (type) ->
            console.debug "Chose order type #{type}"
            $scope.$apply ->
              lieutenant.orders.currentOrder.type = type

            switch type
              when "Move"
                this.transition("dst")
              when "Support", "Convoy"
                this.transition("src")
              when "Hold"
                that = this
                $scope.$apply ->
                  lieutenant.orders.storeOrder()
                  that.transition("start")

        src:
          _onEnter: lieutenant.onEnterWrapper(->
            console.debug this.attr("id")
            lieutenant.fsm.handle("chose.src", this.attr("id"))
          )

          'chose.src': (src) ->
            console.debug "Chose source #{src}"
            $scope.$apply ->
              lieutenant.orders.currentOrder.src = src
            this.transition("dst")

        dst:
          _onEnter: lieutenant.onEnterWrapper(->
            lieutenant.fsm.handle("chose.dst", this.attr("id"))
          )

          'chose.dst': (dst) ->
            console.debug "Chose destination #{dst}"
            $scope.$apply ->
              lieutenant.orders.currentOrder.dst = dst
              lieutenant.orders.storeOrder()
            this.transition("start")
    })

  MovementFSM
)

