define([
  'angular'
  'wsService'
], (
  angular
) ->
  'use strict'

  angular.module('diplomacyServices')
    .factory('GameListService', ['wsService', (wsService) ->
        Service =
          gameList: {}

        uri = "/games/current"

        wsService.registerList(uri, Service.gameList)

        Service.get = ->
          # TODO return a sorted list instead
          wsService.subscribe(uri)
          this.gameList

        Service
    ])
    .factory('GameService', ['wsService', (wsService) ->
        Service =
          games: {}

        uri = (id) -> "/games/#{id}"

        Service.get = (id) ->
          this.games[id] = {}
          wsService.registerList(uri(id), Service.games[id])
          wsService.subscribe(uri(id))
          this.games[id]

        Service
    ])
    .factory('UserService', ['wsService', (wsService) ->
        Service =
          user: {}

        uri = '/user'

        Service.get = ->
          wsService.registerList(uri, Service.user)
          wsService.subscribe(uri)
          this.user

        Service
    ])
)
