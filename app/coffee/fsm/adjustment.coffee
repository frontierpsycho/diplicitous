define([
  'machina'
  'underscore'
], (
  Machina
  _
) ->
  'use strict'

  AdjustmentFSM = ($scope, MapService, lieutenant) ->
    return new Machina.Fsm({
      initialState: 'start'

      states:
        start:
          _onEnter: lieutenant.onEnterWrapper(->
            $scope.$apply =>
              lieutenant.fsm.handle('chose.area', this.attr('id'))
          )

          'chose.area': (abbr) ->
            console.debug "Chose area to build in: #{abbr}"
            currentOrder = lieutenant.orders.currentOrder
            currentOrder.unit_area = abbr

            if abbr of lieutenant.game.Phase.Units
              currentOrder.type = 'Disband'
              lieutenant.fsm.transition("chose_disband")
              lieutenant.orders.storeOrder()
              lieutenant.fsm.transition("start")
            else
              currentOrder.type = 'Build'
              lieutenant.fsm.transition("unit_type")

        unit_type:
          _onEnter: ->
            lieutenant.deactivateProvinces()

            console.debug 'Entered unit_type'

            unitTypes = lieutenant.orders.nextOptions()

            MapService.activateOrders(lieutenant.orders.currentOrder.unit_area, unitTypes)

          'chose.order': (type) ->
            console.debug "Chose unit type #{type}"
            $scope.$apply ->
              lieutenant.orders.currentOrder.unit_type = type
              lieutenant.orders.storeOrder()
              nation = lieutenant.player.Nation
              availableUnits = lieutenant.game.supplyCenters(nation).length - lieutenant.game.units(nation).length
              console.debug 'availableUnits', availableUnits, lieutenant.game.supplyCenters(nation), lieutenant.game.units(nation)
              if _.size(lieutenant.orders.orders) >= availableUnits
                lieutenant.fsm.transition("blocked")
              else
                lieutenant.fsm.transition("start")

        blocked:
          _onEnter: ->
            lieutenant.deactivateProvinces()

            console.debug 'Entered blocked (no more units can be ordered)'

          'order.deleted': (abbr) ->
            lieutenant.fsm.transition("start")

    })

  AdjustmentFSM
)
