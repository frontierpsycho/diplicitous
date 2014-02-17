define([
  'angular'
  'map'
], (
  ng
  Map
) ->
  'use strict'

  diplomacyDirectives = ng.module 'diplomacyDirectives', []

  diplomacyDirectives.directive 'diplomacyMap', () ->

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
