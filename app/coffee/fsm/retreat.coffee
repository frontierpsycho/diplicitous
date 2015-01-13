define([
  'machina'
  'underscore'
], (
  Machina
  _
) ->
  'use strict'

  RetreatFSM = ($scope, newLieutenant) ->
    return new Machina.Fsm({
      initialState: 'start'

      states:
        start:
          _onEnter: newLieutenant.onEnterWrapper(->
            newLieutenant.fsm.handle('chose.area', this.attr('id'))
          )

          'chose.area': (abbr) ->
            console.debug "Chose area to retreat from: #{abbr}"
            currentOrder = newLieutenant.orders.currentOrder
            currentOrder.unit_area = abbr

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
              when "Disband"
                $scope.$apply ->
                  newLieutenant.orders.storeOrder()
                this.transition("start")

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

  RetreatFSM
)

