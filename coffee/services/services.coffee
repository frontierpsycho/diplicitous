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
      Service = { loaded: false }

      uri = "/games/mine"

      Service.subscribe = ->
        wsService.subscribe(uri, {
          target: Service
          name: 'games'
          callback: (games) ->
            Service.loaded = true

            _.chain(games)
              .map((elem) -> [ elem.Id, elem ] )
              .object()
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

        $http(
          method: 'GET'
          url: 'http://' + Config.wsHost + '/token'
          withCredentials: true
        ).then((response) =>
          Service.data = response.data
          Service.token = -> this.data.Encoded
          Service.loaded = true
          console.debug('Token initialized!', Service)
        )

        Service
    ])
)
