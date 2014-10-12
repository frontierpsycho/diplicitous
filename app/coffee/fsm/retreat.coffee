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
            $scope.$apply =>
              newLieutenant.fsm.handle('chose.area', this.attr('id'))
          )

          'chose.area': (abbr) ->
            console.debug "Chose area to retreat from: #{abbr}"
            currentOrder = newLieutenant.orders.currentOrder
            currentOrder.type = 'Move'
            currentOrder.unit_area = abbr

            newLieutenant.fsm.transition("dst")

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

