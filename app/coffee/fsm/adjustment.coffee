define([
  'machina'
  'underscore'
], (
  Machina
  _
) ->
  'use strict'

  AdjustmentFSM = ($scope, newLieutenant) ->
    return new Machina.Fsm({
      initialState: 'start'

      states:
        start:
          _onEnter: newLieutenant.onEnterWrapper(->
            newLieutenant.fsm.handle('chose.area', this.attr('id'))
          )

          'chose.area': (abbr) ->
            console.debug "Chose area to build in: #{abbr}"
            currentOrder = newLieutenant.orders.currentOrder
            currentOrder.unit_area = abbr

            if abbr of $scope.game.Phase.Units
              currentOrder.type = 'Disband'
              newLieutenant.fsm.transition("chose_disband")
              newLieutenant.orders.storeOrder()
              newLieutenant.fsm.transition("start")
            else
              currentOrder.type = 'Build'
              newLieutenant.fsm.transition("unit_type")

        unit_type:
          _onEnter: ->
            newLieutenant.deactivateProvinces()

            console.debug 'Entered unit_type'

            unitTypes = newLieutenant.orders.nextOptions()

            $scope.map.activateOrders(newLieutenant.orders.currentOrder.unit_area, unitTypes)

          'chose.order': (type) ->
            console.debug "Chose unit type #{type}"
            $scope.$apply ->
              newLieutenant.orders.currentOrder.unit_type = type
              newLieutenant.orders.storeOrder()
              nation = newLieutenant.player.Nation
              availableUnits = $scope.game.supplyCenters(nation).length - $scope.game.units(nation).length
              console.debug 'availableUnits', availableUnits, $scope.game.supplyCenters(nation), $scope.game.units(nation)
              if _.size(newLieutenant.orders.orders) >= availableUnits
                newLieutenant.fsm.transition("blocked")
              else
                newLieutenant.fsm.transition("start")

        blocked:
          _onEnter: ->
            newLieutenant.deactivateProvinces()

            console.debug 'Entered blocked (no more units can be ordered)'

          'order.deleted': (abbr) ->
            newLieutenant.fsm.transition("start")

    })

  AdjustmentFSM
)
