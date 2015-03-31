define([
  'angular'
  'underscore'
], (
  angular
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
    'UserService'
    'GameService'
    'MapService'
    'Lieutenant'
    'wsService'
    (
      $scope
      $routeParams
      $interval
      UserService
      GameService
      MapService
      Lieutenant
      wsService
    ) ->
      $scope.map = MapService # TODO remove once all references get replaced by MapService
      $scope.lieutenant = Lieutenant

      deregisterMap = $scope.$watch((-> MapService.loaded), (newValue, oldValue) ->
        console.debug("Controller picked it up")
        if newValue
          GameService.subscribe($scope, $routeParams.gameId)
          UserService.subscribe($scope)

          console.debug "Start watching game to init Lieutenant"
          $scope.$watch('game', (newGame, oldGame) ->
            # if there is a new game, and if we have changed phase
            if newGame? and not (oldGame? and newGame.Phase.Ordinal == oldGame.Phase.Ordinal)
              MapService.refresh(newGame)

              deregisterUser = $scope.$watch('user', (newUser, oldUser) ->
                if newUser? and not _.isEmpty(newUser)
                  # we have both a game and a user
                  Lieutenant.refresh(newGame, newUser)

                  deregisterUser()
              )

              # get initial time left
              $scope.timeLeft = newGame.timeLeft()

              # decrement per second
              $interval((-> $scope.timeLeft -= 1), 1000)

              $scope.timeLeftHumanReadable = ->
                moment.duration($scope.timeLeft, "seconds").humanize()
          )

          deregisterMap()
      )
  ])
)
