define([
  'angular'
  'directives/directives'
], (
  angular
  directives
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('gameState', ['GameService', '$interval', (GameService, $interval) ->
      {
        templateUrl: 'templates/gameState.html'
        replace: true
        restrict: 'E'
        link: ($scope, iElem, iAttr) ->
          $scope.previousPhase = ->
            if (!$scope.isFirstPhase())
              console.log("Displaying previous phase (#{$scope.game.Phase.Ordinal - 1})")
              GameService.subscribePhase($scope.game.Id, $scope.game.Phase.Ordinal - 1)
            else
              console.log("Not displaying previous phase, we're at the first one")

          $scope.firstPhase = ->
            console.log("Displaying first phase")
            GameService.subscribePhase($scope.game.Id, 0)

          $scope.nextPhase = ->
            if (!$scope.isLastPhase())
              console.log("Displaying next phase (#{$scope.game.Phase.Ordinal + 1})")
              GameService.subscribePhase($scope.game.Id, $scope.game.Phase.Ordinal + 1)
            else
              console.log("Not displaying next phase, we're at the last one")

          $scope.lastPhase = ->
            console.log("Displaying last phase")
            GameService.subscribePhase($scope.game.Id, $scope.game.Phases)

          $scope.isLastPhase = ->
            $scope.game?.Phase.Ordinal == $scope.game?.Phases
          $scope.isFirstPhase = ->
            $scope.game?.Phase.Ordinal == 0
      }
    ])
)
