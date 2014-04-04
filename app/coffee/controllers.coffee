define([
  'angular'
  'lieutenant'
  'underscore'
], (
  angular
  Lieutenant
  _
) ->
  'use strict'

  diplomacyControllers = angular.module 'diplomacyControllers', []

  diplomacyControllers.controller('GameListCtrl', [
    '$scope'
    'GameListService'
    ($scope, GameListService) ->
      GameListService.subscribe($scope)
  ])
  .controller('GameCtrl', [
    '$scope'
    '$routeParams'
    'UserService'
    'GameService'
    'wsService'
    (
      $scope
      $routeParams
      UserService
      GameService
      ws
    ) ->
      initLieutenant = (newGame, oldGame) ->
        # on initialization, watcher is called with undefined values
        if newGame?
          $scope.$watch('user', (newUser, oldUser) ->
            if newUser? and not _.isEmpty(newUser)
              $scope.lieutenant = Lieutenant($scope).init(newGame.Phase.Type)
          )

      deregister = $scope.$watch('map.loaded', (newValue, oldValue) ->
        if newValue
          GameService.subscribe($scope, $routeParams.gameId)
          UserService.subscribe($scope)

          console.debug "Start watching game to init Lieutenant"
          $scope.$watch('game', initLieutenant)

          deregister()
      )
  ])
)
