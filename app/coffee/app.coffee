define([
  'angular'
  'angular-route'
  'wsService'
  'services'
  'controllers'
  'directives'
], (
  angular
) ->
  'use strict'

  angular.module('diplomacy', [
    'diplomacyServices'
    'diplomacyControllers'
    'diplomacyDirectives'
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
