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
      hover: []

      addHover: (hoverlist) ->
        for provincePair in hoverlist
          $scope.map.hoverProvince provincePair[0]
        that.hover = hoverlist
      removeHover: ->
        for provincePair in that.hover
          $scope.map.unhoverProvince provincePair[0]
        that.hover = []

      init: (type) ->
        console.debug 'Initializing Lieutenant!'

        switch type
          when 'Movement'
            userDone = $scope.$watch('user.data', (newValue, oldValue) ->
              unless newValue == oldValue
                console.debug "User: #{$scope.user.data.Email}"

                member = _.find($scope.game.data.Members, (mem) -> mem.User.Email == $scope.user.data.Email)

                units = _.filter(_.pairs($scope.game.data.Phase.Units), (pair) -> pair[1].Nation == member.Nation )

                that.fsm = new Machina.Fsm({
                  initialState: 'start'
                  states:
                    start:
                      _onEnter: ->
                        console.debug 'Entered start'

                        that.addHover(units)

                        for provincePair in units
                          $scope.map.clickProvince(provincePair[0], (->
                            that.fsm.handle("chose.unit", this.attr("id"))
                          ))

                      'chose.unit': (abbr) ->
                        that.removeHover()

                        console.debug "Chose unit in #{abbr}"
                        $scope.$apply ->
                          that.currentOrder.src = abbr
                        that.fsm.transition("order_type")

                    order_type:
                      _onEnter: ->
                        console.debug 'Entered order_type'
                })

                userDone()
            )

        return that

    return that

  return Lieutenant
)
