define([
  'angular'
  'machina'
  'underscore'
], (
  angular
  Machina
  _
) ->
  'use strict'

  Lieutenant = ($scope) ->
    that =
      orders: []
      currentOrder: {}

      active: []
      addActiveHandlers: (hoverlist, handler) ->
        for provincePair in hoverlist
          $scope.map.hoverProvince provincePair[0]
          $scope.map.clickProvince(provincePair[0], handler)
        that.active = hoverlist
      removeActiveHandlers: ->
        for provincePair in that.active
          $scope.map.unhoverProvince provincePair[0]
        that.active = []

      onEnterWrapper: (func) ->
        return ->
          that.removeActiveHandlers()
          func()

      init: (type) ->
        console.debug 'Initializing Lieutenant!'

        switch type
          when 'Movement'
            userDone = $scope.$watch('user', (newValue, oldValue) ->
              if newValue
                console.debug "User: #{$scope.user.Email}"

                that.fsm = new Machina.Fsm({
                  initialState: 'start'

                  states:
                    start:
                      _onEnter: that.onEnterWrapper(->
                        console.debug 'Entered start'

                        units = $scope.game.units($scope.user)

                        that.addActiveHandlers(units, ->
                          that.fsm.handle("chose.unit", this.attr("id"))
                        )
                      )

                      'chose.unit': (abbr) ->
                        console.debug "Chose unit in #{abbr}"
                        $scope.$apply ->
                          that.currentOrder.src = abbr
                        that.fsm.transition("order_type")

                    order_type:
                      _onEnter: that.onEnterWrapper(->
                        console.debug 'Entered order_type'
                      )
                })

                userDone()
            )

        return that

    return that

  return Lieutenant
)
