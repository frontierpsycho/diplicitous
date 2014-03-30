define([
  'angular'
  'snap'
  'map'
  'lieutenant'
  'underscore'
  'machina'
], (
  angular
  Snap
  Map
  Lieutenant
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
      initLieutenant = (newValue, oldValue) ->
        # on initialization, watcher is called with undefined values
        unless newValue == oldValue and oldValue == undefined
          $scope.lieutenant = Lieutenant($scope).init(newValue.Phase.Type)

      deregister = $scope.$watch('map.loaded', (newValue, oldValue) ->
        if newValue
          $scope.game = GameService.get($routeParams.gameId)
          $scope.user = UserService.get()

          console.debug "Start watching game to init Lieutenant"
          $scope.$watch('game.data', initLieutenant)

          deregister()
      )
  ])
)
