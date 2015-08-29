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
          iElem.find('.navigation.left').click(->
            console.log("Displaying previous phase (#{$scope.game.Phase.Ordinal - 1})")
            GamePhaseService.subscribe($scope, $scope.game.Id, $scope.game.Phase.Ordinal - 1)
          )
          iElem.find('.navigation.right').click(->
            console.log("Displaying next phase (#{$scope.game.Phase.Ordinal + 1})")
            GamePhaseService.subscribe($scope, $scope.game.Id, $scope.game.Phase.Ordinal + 1)
          )
      }
    ])
)
