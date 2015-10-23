define([
  'angular'
  'angular-route'
  'angular-sanitize'
  'angular-hotkeys'
  'wsService'
  'services/services'
  'services/map'
  'services/lieutenant'
  'controllers'
  'directives/dipOrders'
  'directives/dipPowers'
  'directives/dipPlayer'
  'directives/diplomacyMap'
  'directives/gameState'
  'directives/mapOrders'
  'directives/menu'
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
    'cfp.hotkeys'
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
