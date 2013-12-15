'use strict'

angular.module('diplomacy', [
  'diplomacyServices'
  'diplomacyControllers'
  'ngRoute'
])
  .config(['$routeProvider', ($routeProvider) ->

    $routeProvider
      .when "/game/:gameId",
        templateUrl: 'game.html'
        controller: "GameCtrl"
  ])

angular.bootstrap document, ['diplomacy']
