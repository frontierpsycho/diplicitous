define([
  'angular'
  'directives/directives'
], (
  angular
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive 'diplomacyMap', ["MapService", (MapService) ->
      return {
        templateUrl: "img/classical.svg"
        replace: true
        restrict: 'E'
        link: {
          pre: (scope, iElement, tAttrs, transclude) ->
            # the map is loaded, init map service
            MapService.init()
        }
      }]
)
