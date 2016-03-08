define([
  'angular'
  'lodash'
  'services/services'
], (
  angular
  _
) ->
  'use strict'

  angular.module('diplomacyServices')
    .service('Postman', [
      'wsService'
      (ws) ->
        Service = {}

        uriMessages = (gameId) -> "/games/#{gameId}/messages"

        Service.subscribeMessages = (gameId) ->
          ws.subscribe(uriMessages(gameId), {
            target: Service
            name: 'messages'
          })

        Service
    ])

)
