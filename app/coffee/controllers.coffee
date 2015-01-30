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
    '$interval'
    'UserService'
    'GameService'
    'wsService'
    (
      $scope
      $routeParams
      $interval
      UserService
      GameService
      wsService
    ) ->
      initPhase = (newGame, oldGame) ->
        # on initialization, watcher is called with undefined values
        if newGame?
          # the new game is the same as the old one, don't reinit lieutenant
          unless oldGame? and newGame.Phase.Ordinal == oldGame.Phase.Ordinal
            $scope.map.refresh(newGame)

            if $scope.lieutenant?
              $scope.lieutenant.deactivateProvinces()
              delete $scope.lieutenant

            # get initial time left
            $scope.timeLeft = newGame.timeLeft()

            # decrement per second
            $interval((-> $scope.timeLeft -= 1), 1000)

            $scope.timeLeftHumanReadable = ->
              moment.duration($scope.timeLeft, "seconds").humanize()

            deregisterUser = $scope.$watch('user', (newUser, oldUser) ->
              # only init lieutenant once per phase
              if newUser? and not _.isEmpty(newUser) and not $scope.lieutenant?
                $scope.lieutenant = Lieutenant($scope, wsService).init(newGame.Phase.Type)

                deregisterUser()
            )

      deregisterMap = $scope.$watch('map.loaded', (newValue, oldValue) ->
        if newValue
          GameService.subscribe($scope, $routeParams.gameId)
          UserService.subscribe($scope)

          console.debug "Start watching game to init Lieutenant"
          $scope.$watch('game', initPhase)

          deregisterMap()
      )
  ])
)
