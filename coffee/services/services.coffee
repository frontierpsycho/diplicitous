define([
  'config'
  'angular'
  'models/Game'
  'wsService'
], (
  Config
  angular
  Game
) ->
  'use strict'

  angular.module('diplomacyServices')
    .factory('GameListService', ['wsService', (wsService) ->
      Service = { loaded: false, games: {} }

      uriMine = "/games/mine"
      uriOpen = "/games/open"
      uriClosed = "/games/closed"

      Service.subscribeMine = ->
        wsService.subscribe(uriMine, {
          target: Service.games
          name: 'mine'
          callback: (games) ->
            Service.loaded = true

            _.chain(games)
              .map((elem) -> [ elem.Id, elem ] )
              .fromPairs()
              .value()
        })

      Service.subscribeOpen = ->
        wsService.subscribe(uriOpen, {
          target: Service.games
          name: 'open'
          callback: (games) ->
            Service.loaded = true

            _.chain(games)
              .map((elem) -> [ elem.Id, elem ] )
              .fromPairs()
              .value()
        })

      Service.subscribeClosed = ->
        wsService.subscribe(uriClosed, {
          target: Service.games
          name: 'closed'
          callback: (games) ->
            Service.loaded = true

            _.chain(games)
              .map((elem) -> [ elem.Id, elem ] )
              .fromPairs()
              .value()
        })

      Service
    ])
    .factory('GameService', [
      'wsService'
      (
        wsService
      ) ->
        Service = {}

        uri = (gameId) -> "/games/#{gameId}"

        Service.subscribe = (gameId) ->
          wsService.subscribe(uri(gameId), {
            target: Service
            name: 'game'
            callback: (data) ->
              Game(data)
          })

        uriPhase = (gameId, phase) -> "#{uri(gameId)}/#{phase}"

        Service.subscribePhase = (gameId, phase) ->
          wsService.subscribe(uriPhase(gameId, phase), {
            target: Service
            name: 'game'
            callback: (data) ->
              Game(data)
          })

        Service
    ])
    .factory('UserService', [
      'wsService'
      (
        wsService
      ) ->
        Service = {}

        uri = '/user'

        Service.subscribe = (target) ->
          wsService.subscribe(uri, {
            target: Service
            name: 'user'
            callback: (user) ->
              Service.loaded = true

              user
          })

        Service
    ])
    .factory('TokenService', [
      '$http'
      (
        $http
      ) ->
        Service = {}
        console.debug('Initializing Token Service')
        Service.loaded = false

        Service.refresh = ->
          Service.loaded = false
          $http(
            method: 'GET'
            url: 'http://' + Config.wsHost + '/token'
            withCredentials: true
          ).then((response) =>
            # FIXME what if data is not defined? Dimwit.
            Service.data = response.data
            Service.email = -> this.data.Principal
            Service.token = -> this.data.Encoded
            Service.loaded = true
            console.debug('Token initialized!', Service)
          )

        Service.refresh()

        Service
    ])
)
