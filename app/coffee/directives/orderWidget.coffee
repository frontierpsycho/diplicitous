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

  angular.module('diplomacyDirectives')
    .directive 'orderWidget', ['wsService', (ws) ->
      return {
        templateUrl: 'templates/orderWidget.html'
        replace: true
        restrict: 'E'
        link: {
          pre: (scope, iElement, tAttrs, transclude) ->
            console.log "Order widget linking"

            iElement.find("button").click(->
              console.debug("RPC?", scope.lieutenant.orders.orders)

              for abbr, order of scope.lieutenant.orders.orders
                ws.sendRPC(
                  "SetOrder"
                  {
                    'GameId': scope.game.Id
                    'Order': order.toDiplicity()
                  }
                )
                console.debug order.toDiplicity()
            )

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
    ]
)
