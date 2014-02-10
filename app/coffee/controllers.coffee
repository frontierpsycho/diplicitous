define([
  'angular'
  'snap'
], (
  ng
  Snap
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

      svgData = null

      $scope.map = Snap("#map")
      Snap.load("img/classical.svg", (data) ->
        console.log "Loaded map!"
        svgData = data
        data.select("#provinces").attr
          style: ""
        provinces = data.selectAll("#provinces path")
        for province in provinces
          province.attr
            style: ""
            fill: "#FFFFFF"
            "fill-opacity": "0"
        $scope.map.append(data)

        deregisterWatch = $scope.$watch('game', ->
          console.debug "Game loaded!", $scope.game.data.Id

          for provinceName,unit of $scope.game.data.Phase.Units
            provinceName = provinceName.replace '/', '-'

            province = $scope.map.select("##{provinceName}")

            province.attr
              style: ""
              fill: powers[unit.Nation].colour
              "fill-opacity": "0.8"

            deregisterWatch()
        )

      )

  ])
)
