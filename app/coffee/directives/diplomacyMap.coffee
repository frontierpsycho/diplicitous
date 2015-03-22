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
        templateUrl: "img/classical.svg"
        replace: true
        restrict: 'E'
        link: {
          pre: (scope, iElement, tAttrs, transclude) ->
            scope.map = Map($q, "#map", iElement)
        }
      }]
)
