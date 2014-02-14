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

  powers =
    Austria:
      colour: "#B22222"
    England:
      colour: "#4B0082"
    France:
      colour: "#ADD8E6"
    Germany:
      colour: "#414141"
    Italy:
      colour: "#3E954A"
    Russia:
      colour: "#E5E5E5"
    Turkey:
      colour: "#F0E68C"

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
