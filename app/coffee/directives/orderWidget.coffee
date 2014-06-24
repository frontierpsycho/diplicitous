define([
  'angular'
  'objects/map'
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

  secondaryTypeSymbols =
    "Move": ""
    "Support": "&rarr;"
    "Hold": ""

  angular.module('diplomacyDirectives')
    .directive('orderWidget', ['wsService', (ws) ->
      {
        templateUrl: 'templates/orderWidget.html'
        replace: true
        restrict: 'E'
        link: ($scope) ->
          console.debug "Order widget linking"

          $scope.commitOrders = ->
            ws.sendRPC("Commit", { "PhaseId": $scope.game.Phase.Id }, ->
              $scope.$apply ->
                $scope.lieutenant.player.Committed = true
            )

          $scope.uncommitOrders = ->
            ws.sendRPC("Uncommit", { "PhaseId": $scope.game.Phase.Id }, ->
              $scope.$apply ->
                $scope.lieutenant.player.Committed = false
            )

          $scope.sendOrders = ->
            _.chain($scope.lieutenant.orders.orders)
              .filter((order) -> (not order.committed))
              .each((order) ->
                ws.sendRPC(
                  "SetOrder"
                  {
                    "GameId": $scope.game.Id
                    "Order": order.toDiplicity()
                  }
                  ((iOrder) ->
                    ->
                      $scope.$apply ->
                        iOrder.committed = true
                  )(order)
                )
                console.debug "Sent", order.toDiplicity()
              )

          $scope.typeSymbols = typeSymbols

          $scope.secondaryTypeSymbols = secondaryTypeSymbols
      }
    ])
    .directive('existingOrder', ->
      {
        templateUrl: 'templates/existingOrder.html'
        replace: true
        restrict: 'E'
        scope:
          order: "=order"
        link: ($scope) ->
          console.debug "Existing order widget linking"

          $scope.typeSymbols = typeSymbols

          $scope.secondaryTypeSymbols = secondaryTypeSymbols
      }
    )
)
