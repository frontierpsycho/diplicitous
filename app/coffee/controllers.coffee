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
    (
      $scope
      $routeParams
      GameService
    ) ->
      $scope.game = GameService.get($routeParams.gameId)

      initLieutenant = (newValue, oldValue) ->
        # on initialization, watcher is called with undefined values
        unless newValue == oldValue
          if newValue.Phase.Type == 'Movement'
            console.debug 'Initializing Lieutenant!'

            $scope.lieutenant = new Machina.Fsm({
              initialState: 'start'
              states:
                start:
                  _onEnter: ->
                    console.debug 'Entered start'
                  'choose.unit': (abbr) ->
                    console.debug "Chose unit in #{abbr}"
            })

      $scope.$watch('game.data', initLieutenant)
  ])
)
