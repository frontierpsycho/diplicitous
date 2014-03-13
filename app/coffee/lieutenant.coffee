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
      init: (type) ->
        console.debug 'Initializing Lieutenant!'

        switch type
          when 'Movement'
            userDone = $scope.$watch('user.data', (newValue, oldValue) ->
              if newValue?
                console.debug "User: #{$scope.user.data.Email}"

                member = _.find($scope.game.data.Members, (mem) -> mem.User.Email == $scope.user.data.Email)

                units = _.filter(_.pairs($scope.game.data.Phase.Units), (pair) -> pair[1].Nation == member.Nation )

                that.lieutenant = new Machina.Fsm({
                  initialState: 'start'
                  states:
                    start:
                      _onEnter: ->
                        console.debug 'Entered start'
                        for provincePair in units
                          $scope.map.hoverProvince provincePair[0]

                      'choose.unit': (abbr) ->
                        console.debug "Chose unit in #{abbr}"
                })

                userDone()
            )

    return that

  return Lieutenant
)
