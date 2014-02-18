define([
  'angular'
  'snap'
  'map'
], (
  angular
  Snap
  Map
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
  ])
)
