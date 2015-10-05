define([
  'angular'
  'moment'
  'lodash'
], (
  angular
  moment
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
    '$interval'
    'hotkeys'
    'UserService'
    'GameService'
    'MapService'
    'Lieutenant'
    'wsService'
    (
      $scope
      $routeParams
      $interval
      hotkeys
      UserService
      GameService
      MapService
      Lieutenant
      wsService
    ) ->
      $scope.lieutenant = Lieutenant

      hotkeys.bindTo($scope)
        .add(
          combo: 'left'
          description: 'Display the previous phase'
          callback: -> $scope.previousPhase()
        )
        .add(
          combo: 'right'
          description: 'Display the next phase'
          callback: -> $scope.nextPhase()
        )
        .add(
          combo: 'shift+left'
          description: 'Display the first phase'
          callback: -> $scope.firstPhase()
        )
        .add(
          combo: 'shift+right'
          description: 'Display the last phase'
          callback: -> $scope.lastPhase()
        )
        .add(
          combo: 'esc'
          description: 'Cancel current order'
          callback: -> Lieutenant.cancelOrder()
        )

      unwatchMap = $scope.$watch((-> MapService.loaded), (newValue, oldValue) ->
        if newValue
          GameService.subscribe($scope, $routeParams.gameId)
          UserService.subscribe($scope)

          console.debug "Start watching game to init Lieutenant"
          $scope.$watch('game', (newGame, oldGame) ->
            # if there is a new game, and if we have changed phase
            if newGame? and not (oldGame? and newGame.Phase.Ordinal == oldGame.Phase.Ordinal)
              MapService.refresh(newGame)

              unwatchUser = $scope.$watch('user', (newUser, oldUser) ->
                if newUser? and not _.isEmpty(newUser)
                  # we have both a game and a user
                  Lieutenant.refresh(newGame, newUser)

                  unwatchUser()
              )

              # get initial time left
              $scope.timeLeft = newGame.timeLeft()

              # decrement per second
              $interval((-> $scope.timeLeft -= 1), 1000)

              $scope.timeLeftHumanReadable = ->
                moment.duration($scope.timeLeft, "seconds").humanize()
          )

          unwatchMap()
      )
  ])
)
