define([
  'angular'
  'directives/directives'
], (
  angular
  directives
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('gameState', ['$interval', ($interval) ->
      {
        templateUrl: 'templates/gameState.html'
        replace: true
        restrict: 'E'
      }
    ])
)
