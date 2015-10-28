define([
  'config'
  'angular'
  'moment'
  'lodash'
], (
  Config
  angular
  moment
  _
) ->
  'use strict'

  diplomacyControllers = angular.module 'diplomacyControllers', []

  diplomacyControllers.controller('GameListCtrl', [
    '$scope'
    'GameListService'
    'UserService'
    'wsService'
    ($scope, GameListService, UserService, wsService) ->
      $scope.$watch((-> wsService.connected), (newValue, oldValue) ->
        if newValue
          UserService.subscribe()
          GameListService.subscribeMine()
          GameListService.subscribeOpen()
          GameListService.subscribeClosed()

          $scope.$watch((-> GameListService.loaded), (loaded) ->
            if loaded
              $scope.games = GameListService.games
          )
      )
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

      $scope.$watch((-> wsService.connected), (newValue, oldValue) ->
        if newValue
          unwatchMap = $scope.$watch((-> MapService.loaded), (newValue, oldValue) ->
            if newValue
              GameService.subscribe($routeParams.gameId)
              UserService.subscribe()

              console.debug "Start watching game to init Lieutenant"
              $scope.$watch((-> GameService.game), (newGame, oldGame) ->
                # if there is a new game, and if we have changed phase
                if newGame? or (oldGame? and newGame.Phase.Ordinal == oldGame.Phase.Ordinal)
                  $scope.game = GameService.game

                  MapService.refresh(newGame)

                  unwatchUser = $scope.$watch((-> UserService.user), (newUser, oldUser) ->
                    # backend returns empty user when no user available/accessible
                    unless _.isEmpty(newUser)
                      $scope.user = UserService.user

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
      )
  ])
)
