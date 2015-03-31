define([
  'angular'
  'wsService'
  'directives/directives'
], (
  angular
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
    .directive('dipOrders', ['wsService', 'Lieutenant', (ws, Lieutenant) ->
      {
        templateUrl: 'templates/dipOrders.html'
        replace: true
        restrict: 'E'
        link: ($scope) ->
          console.debug "Order widget linking"

          $scope.commitOrders = ->
            Lieutenant.commitOrders()

          $scope.uncommitOrders = ->
            Lieutenant.uncommitOrders()

          $scope.sendOrders = ->
            Lieutenant.sendOrders()

          $scope.typeSymbols = typeSymbols

          $scope.secondaryTypeSymbols = secondaryTypeSymbols
      }
    ])
    .directive('order', ['wsService', 'Lieutenant', (ws, Lieutenant) ->
      {
        templateUrl: 'templates/order.html'
        replace: true
        restrict: 'E'
        scope:
          order: "="
          lieutenant: "="
          newOrder: "@"
        link: ($scope) ->
          console.debug "Existing order widget linking"

          $scope.typeSymbols = typeSymbols

          $scope.secondaryTypeSymbols = secondaryTypeSymbols

          $scope.deleteOrder = (order) ->
            Lieutenant.deleteRemoteOrder(order)
            console.debug "Sent order deletion (#{order.unit_area})"

          $scope.cancelOrder = ->
            Lieutenant.cancelOrder()
      }
    ])
)
