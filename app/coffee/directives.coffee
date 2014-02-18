define([
  'angular'
  'map'
], (
  angular
  Map
) ->
  'use strict'

  diplomacyDirectives = angular.module 'diplomacyDirectives', []

  diplomacyDirectives.directive 'diplomacyMap', ->

    return {
      template: '<div id="map"></div>'
      replace: true
      restrict: 'E'
      link: {
        pre: (scope, iElement, tAttrs, transclude) ->
          scope.map = Map(scope, "#map", "img/classical.svg")
      }
    }
)
