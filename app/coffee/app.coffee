define([
  'angular'
  'angular-route'
  'wsService'
  'services'
  'controllers'
], (ng) ->
  'use strict'

  angular.module('diplomacy', [
    'diplomacyServices'
    'diplomacyControllers'
    'ngRoute'
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
