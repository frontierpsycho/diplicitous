define([
  'angular'
  'map'
], (
  angular
  Map
) ->
  'use strict'

  angular.module('diplomacyDirectives', [])
    .directive 'diplomacyMap', ->
      return {
        template: '<div id="map"></div>'
        replace: true
        restrict: 'E'
        link: {
          pre: (scope, iElement, tAttrs, transclude) ->
            scope.map = Map(scope, "#map", "img/classical.svg")
        }
      }
    .directive 'orderWidget', ->
      return {
        templateUrl: 'templates/orderWidget.html'
        replace: true
        restrict: 'E'
        link: {
          pre: (scope, iElement, tAttrs, transclude) ->
            console.log "Order widget linking"
        }
      }
)
