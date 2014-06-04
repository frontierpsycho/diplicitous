define([
  'angular'
  'objects/map'
  'directives/directives'
], (
  angular
  Map
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive 'orderWidget', ->
      return {
        templateUrl: 'templates/orderWidget.html'
        replace: true
        restrict: 'E'
        link: {
          pre: (scope, iElement, tAttrs, transclude) ->
            console.log "Order widget linking"

            scope.typeSymbols =
              "Move": "&rarr;"
              "Support": "S"
              "Hold": "H"

            scope.secondaryTypeSymbols =
              "Move": ""
              "Support": "&rarr;"
              "Hold": ""
        }
      }
)
