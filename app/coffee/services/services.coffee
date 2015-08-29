define([
  'angular'
  'models/Game'
  'wsService'
], (
  angular
  Game
) ->
  'use strict'

  angular.module('diplomacyServices')
    .factory('GameListService', ['wsService', (wsService) ->
      Service = {}

      uri = "/games/mine"

      Service.subscribe = (target) ->
        wsService.subscribe(uri, {
          target: target
          name: 'games'
          callback: (games) ->
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

        uri = (id) -> "/games/#{id}"

        Service.subscribe = (target, id) ->
          wsService.subscribe(uri(id), {
            target: target
            name: 'game'
            callback: (data) ->
              Game(data)
          })

        Service
    ])
    .factory('GamePhaseService', [
      'wsService'
      (
        wsService
      ) ->
        Service = {}

        uri = (id, phase) -> "/games/#{id}/#{phase}"

        Service.subscribe = (target, id, phase) ->
          wsService.subscribe(uri(id, phase), {
            target: target
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
            target: target
            name: 'user'
          })

        Service
    ])
)
