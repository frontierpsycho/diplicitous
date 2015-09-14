define([
  'angular'
  'directives/directives'
], (
  angular
  directives
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('gameState', ['GamePhaseService', '$interval', (GamePhaseService, $interval) ->
      {
        templateUrl: 'templates/gameState.html'
        replace: true
        restrict: 'E'
        link: ($scope, iElem, iAttr) ->
          $scope.previousPhase = ->
            console.log("Displaying previous phase (#{$scope.game.Phase.Ordinal - 1})")
            GamePhaseService.subscribe($scope, $scope.game.Id, $scope.game.Phase.Ordinal - 1)

          $scope.firstPhase = ->
            console.log("Displaying first phase")
            GamePhaseService.subscribe($scope, $scope.game.Id, 0)

          $scope.nextPhase = ->
            console.log("Displaying next phase (#{$scope.game.Phase.Ordinal + 1})")
            GamePhaseService.subscribe($scope, $scope.game.Id, $scope.game.Phase.Ordinal + 1)

          $scope.lastPhase = ->
            console.log("Displaying last phase")
            GamePhaseService.subscribe($scope, $scope.game.Id, $scope.game.Phases)

          $scope.isLastPhase = ->
            $scope.game?.Phase.Ordinal == $scope.game?.Phases
          $scope.isFirstPhase = ->
            $scope.game?.Phase.Ordinal == 0
      }
    ])
)
