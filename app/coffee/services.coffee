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

        uri = "/games/mine"

        wsService.registerList(uri, Service.gameList)

        Service.get = ->
          # TODO return a sorted list instead
          wsService.subscribe(uri)
          this.gameList

        Service
    ])
    .factory('GameService', [
      'wsService'
      '$rootScope'
      (
        wsService
        $rootScope
      ) ->
        Service =
          games: {}

        uri = (id) -> "/games/#{id}"

        Service.get = (id) ->
          this.games[id] = {}
          wsService.registerList(uri(id), Service.games[id])
          wsService.subscribe(uri(id), (data) ->
            $rootScope.$apply ->
              Service.games[id] = data
          )
          this.games[id]

        Service
    ])
    .factory('UserService', [
      'wsService'
      '$rootScope'
      (
        wsService
        $rootScope
      ) ->
        Service =
          user: {}

        uri = '/user'

        Service.get = ->
          #wsService.registerList(uri, Service.user)
          wsService.subscribe(uri, (data) ->
            $rootScope.$apply ->
              Service.user = data
          )
          this.user

        Service
    ])
)
