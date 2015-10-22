define([
  'machina'
  'lodash'
], (
  Machina
  _
) ->
  'use strict'

  RetreatFSM = ($scope, MapService, lieutenant) ->
    return new Machina.Fsm({
      initialState: 'start'

      states:
        start:
          _onEnter: lieutenant.onEnterWrapper(->
            $scope.$apply =>
              lieutenant.fsm.handle('chose.area', this.attr('id'))
          )

          'chose.area': (abbr) ->
            console.debug "Chose area to retreat from: #{abbr}"
            currentOrder = lieutenant.orders.currentOrder
            currentOrder.unit_area = abbr

            lieutenant.fsm.transition("order_type")

        order_type:
          _onEnter: ->
            lieutenant.deactivateProvinces()

            console.debug 'Entered order_type'

            orderTypes = lieutenant.orders.nextOptions()

            MapService.activateOrders(lieutenant.orders.currentOrder.unit_area, orderTypes)

          'chose.order': (type) ->
            console.debug "Chose order type #{type}"
            $scope.$apply ->
              lieutenant.orders.currentOrder.type = type

            switch type
              when "Move"
                this.transition("dst")
              when "Disband"
                $scope.$apply ->
                  lieutenant.orders.storeOrder()
                this.transition("start")

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

  RetreatFSM
)

