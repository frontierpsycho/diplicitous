define([
  'angular'
  'directives/directives'
  'lodash'
], (
  angular
  directives
  _
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('dipPlayer', ->
      {
        templateUrl: 'templates/dipPlayer.html'
        replace: true
        restrict: 'E'
        link: ($scope, iElem, iAttr) ->
          $scope.$watch('lieutenant.player', (player, oldValue) ->
          )
      }
    )
)
