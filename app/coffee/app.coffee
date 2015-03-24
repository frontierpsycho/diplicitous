define([
  'angular'
  'angular-route'
  'angular-sanitize'
  'wsService'
  'services/services'
  'services/map'
  'controllers'
  'directives/dipOrders'
  'directives/dipPowers'
  'directives/dipPlayer'
  'directives/diplomacyMap'
  'directives/gameState'
  'directives/mapOrders'
], (
  angular
) ->
  'use strict'

  angular.module('diplomacy', [
    'diplomacyServices'
    'diplomacyControllers'
    'diplomacyDirectives'
    'ngRoute'
    'ngSanitize'
  ])
    .config(['$routeProvider', ($routeProvider) ->

      $routeProvider
        .when "/games",
          templateUrl: 'views/games.html'
          controller: "GameListCtrl"
        .when "/game/:gameId",
          templateUrl: 'views/game.html'
          controller: "GameCtrl"
    ])
)
