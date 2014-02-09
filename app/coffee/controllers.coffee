define([
  'angular'
  'snap'
], (
  ng
  Snap
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

      s = Snap("#map")
      Snap.load("img/classical.svg", (data) ->
        console.log "Loaded map!"
        data.select("#provinces").attr
          style: ""
        provinces = data.selectAll("#provinces path")
        for province in provinces
          province.attr
            style: ""
            fill: "#FFFFFF"
            "fill-opacity": "0"
        s.append(data)
      )

  ])
)
