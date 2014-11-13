define([
  'angular'
  'models/Map'
  'wsService'
  'directives/directives'
], (
  angular
  Map
  ws
  directives
) ->
  'use strict'

  typeSymbols =
    "Move": "&rarr;"
    "Support": "S"
    "Hold": "H"
    "Convoy": "C"
    "Build": "B"
    "Disband": "D"

  secondaryTypeSymbols =
    "Move": ""
    "Support": "&rarr;"
    "Hold": ""
    "Convoy": "&rarr;"
    "Build": ""
    "Disband": ""

  angular.module('diplomacyDirectives')
    .directive('orderWidget', ['wsService', (ws) ->
      {
        templateUrl: 'templates/orderWidget.html'
        replace: true
        restrict: 'E'
        link: ($scope) ->
          console.debug "Order widget linking"

          $scope.cancelOrder = ->
            $scope.lieutenant.cancelOrder()

          $scope.commitOrders = ->
            $scope.lieutenant.commitOrders()

          $scope.uncommitOrders = ->
            $scope.lieutenant.uncommitOrders()

          $scope.sendOrders = ->
            $scope.lieutenant.sendOrders()

          $scope.typeSymbols = typeSymbols

          $scope.secondaryTypeSymbols = secondaryTypeSymbols
      }
    ])
    .directive('existingOrder', ['wsService', (ws) ->
      {
        templateUrl: 'templates/existingOrder.html'
        replace: true
        restrict: 'E'
        scope:
          order: "="
          game: "="
          lieutenant: "="
        link: ($scope) ->
          console.debug "Existing order widget linking"

          $scope.typeSymbols = typeSymbols

          $scope.secondaryTypeSymbols = secondaryTypeSymbols

          $scope.deleteOrder = (order) ->
            $scope.lieutenant.deleteRemoteOrder(order)
            console.debug "Sent order deletion (#{order.unit_area})"
      }
    ])
)
