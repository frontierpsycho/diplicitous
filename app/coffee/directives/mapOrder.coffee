define([
  'angular'
  'directives/directives'
], (
  angular
  directives
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('mapOrder', ->
      {
        template: "<!-- Hello, nurse! -->"
        replace: false
        restrict: 'C'
      }
    )
)
