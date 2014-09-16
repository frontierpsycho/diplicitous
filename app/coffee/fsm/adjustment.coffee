define([
  'machina'
], (
  Machina
) ->
  'use strict'

  AdjustmentFSM = ($scope, newLieutenant) ->
    return new Machina.Fsm({
      initialState: 'start'

      states:
        start:
          _onEnter: newLieutenant.onEnterWrapper(->
            $scope.$apply =>
              newLieutenant.fsm.handle('chose.area', this.attr('id'))
          )

          'chose.area': (abbr) ->
            console.debug "Chose area to build in: #{abbr}"
            currentOrder = newLieutenant.orders.currentOrder
            currentOrder.unit_area = abbr


            if abbr in $scope.game.Phase.Units
              currentOrder.type = 'Disband'
            else
              currentOrder.type = 'Build'

            newLieutenant.fsm.transition("unit_type")

        unit_type:
          _onEnter: ->
            newLieutenant.removeActiveHandlers()

            console.debug 'Entered order_type'

            unit_types = ["Army", "Fleet"]

            $scope.map.activateBuildOptions(newLieutenant.orders.currentOrder.unit_area)

          'chose.unit': (type) ->
            console.debug "Chose unit type #{type}"
            $scope.$apply ->
              newLieutenant.orders.currentOrder.unit_type = type
              newLieutenant.orders.storeOrder()
              newLieutenant.fsm.transition("start")

    })

  AdjustmentFSM
)