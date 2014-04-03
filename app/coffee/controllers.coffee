define([
  'angular'
  'snap'
  'map'
  'lieutenant'
  'objects/Game'
  'underscore'
  'machina'
], (
  angular
  Snap
  Map
  Lieutenant
  Game
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
    'wsService'
    (
      $scope
      $routeParams
      ws
    ) ->
      initLieutenant = (newValue, oldValue) ->
        # on initialization, watcher is called with undefined values
        if newValue
          $scope.lieutenant = Lieutenant($scope).init(newValue.Phase.Type)

      deregister = $scope.$watch('map.loaded', (newValue, oldValue) ->
        if newValue
          $scope.game = undefined
          $scope.user = undefined

          ws.subscribe("/games/#{$routeParams.gameId}", (data) ->
            $scope.$apply ->
              $scope.game = Game(data)
          )
          ws.subscribe("/user", (data) ->
            $scope.$apply ->
              $scope.user = data
          )

          console.debug "Start watching game to init Lieutenant"
          $scope.$watch('game', initLieutenant)

          deregister()
      )
  ])
)
