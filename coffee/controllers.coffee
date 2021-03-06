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
    'Postman'
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
      Postman
      wsService
    ) ->
      $scope.lieutenant = Lieutenant
      $scope.postman = Postman

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
        .add(
          combo: 'ctrl+z'
          description: 'Toggle zoom'
          callback: ->
            if $scope.zoomed # TODO get actual viewbox and compare to unzoomed
              MapService.setViewBox("0 0 1407 1186" ) # TODO blergh get original when loading, restore to that
              $scope.zoomed = false
            else
              MapService.zoomPercent(70)
              $scope.zoomed = true
        )

      $scope.zoomed = false

      $scope.activeTab = "powers"

      $scope.changeTab = (newTabName) ->
        if $("#sidebar .tabs [value='#{newTabName}']").length > 0
          $scope.activeTab = newTabName
        else
          console.warn("Inexistent tab!", newTabName)

      $scope.$watch((-> wsService.connected), (newValue, oldValue) ->
        if newValue
          unwatchMap = $scope.$watch((-> MapService.loaded), (newValue, oldValue) ->
            if newValue
              GameService.subscribe($routeParams.gameId)
              Postman.subscribeMessages($routeParams.gameId)
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
