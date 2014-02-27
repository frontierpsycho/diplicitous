define([
  'angular'
  'snap'
  'map'
  'underscore'
  'machina'
], (
  angular
  Snap
  Map
  _
  Machina
) ->
  'use strict'

  diplomacyControllers = angular.module 'diplomacyControllers', []

  diplomacyControllers.controller('GameListCtrl', [
    '$scope'
    'GameListService'
    ($scope, GameListService) ->
      $scope.games = GameListService.get()
  ])
  .controller('GameCtrl', [
    '$scope'
    '$routeParams'
    'GameService'
    'UserService'
    (
      $scope
      $routeParams
      GameService
      UserService
    ) ->
      $scope.game = GameService.get($routeParams.gameId)
      $scope.user = UserService.get()

      initLieutenant = (newValue, oldValue) ->
        # on initialization, watcher is called with undefined values
        unless newValue == oldValue
          switch newValue.Phase.Type 
            when 'Movement'
              userDone = $scope.$watch('user.data', (newValue, oldValue) ->
                unless newValue == oldValue
                  console.debug "User: #{$scope.user.data.Email}"

                  member = _.find($scope.game.data.Members, (mem) -> mem.User.Email == $scope.user.data.Email)

                  units = _.filter(_.pairs($scope.game.data.Phase.Units), (pair) -> pair[1].Nation == member.Nation )

                  console.debug units

                  console.debug 'Initializing Lieutenant!'

                  $scope.lieutenant = new Machina.Fsm({
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


      $scope.$watch('game.data', initLieutenant)
  ])
)
