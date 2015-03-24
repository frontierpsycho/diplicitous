define([
  'angular'
  'directives/directives'
], (
  angular
  directives
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('mapOrders', ->
      {
        templateUrl: "templates/mapOrders.html"
        replace: true
        templateNamespace: "svg"
      }
    )
)
