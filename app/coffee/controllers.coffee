define([
  'angular'
  'snap'
  'map'
], (
  ng
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

      # yuck, must ask StackOverflow!
      # perhaps a directive?
      map = Map($scope, "#map", "img/classical.svg")
  ])
)
