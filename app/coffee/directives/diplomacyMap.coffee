define([
  'angular'
  'models/Map'
  'directives/directives'
], (
  angular
  Map
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive 'diplomacyMap', ["$q", ($q) ->
      return {
        template: '<div id="map"></div>'
        replace: true
        restrict: 'E'
        link: {
          pre: (scope, iElement, tAttrs, transclude) ->
            scope.map = Map(scope, $q, "#map", "img/classical.svg")
        }
      }]
)
