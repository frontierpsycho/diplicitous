define([
  'angular'
  'directives/directives'
], (
  angular
  directives
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('powersWidget', ->
      {
        templateUrl: 'templates/powersWidget.html'
        replace: true
        restrict: 'E'
        link: ($scope, iElem, iAttr) ->
          $scope.$watch('game', (game, oldValue) ->
            if game?
              $scope.powers = game.Members
          )
      }
    )
)
