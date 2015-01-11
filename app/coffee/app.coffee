define([
  'angular'
  'angular-route'
  'angular-sanitize'
  'wsService'
  'services'
  'controllers'
  'directives/dipOrders'
  'directives/dipPowers'
  'directives/diplomacyMap'
  'directives/gameState'
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
