'use strict'

diplomacyControllers = angular.module 'diplomacyControllers', ['ngRoute']

diplomacyControllers.controller('GameListCtrl', [
  '$scope'
  'GameListService'
  ($scope, GameListService) ->
    $scope.games = GameListService.get()
])
  .controller('GameCtrl', [
    '$scope'
    '$routeParams'
    (
      $scope
      $routeParams
    ) ->
      $scope.game = {}

      console.debug 'GameCtrl'
  ])

