define([
  'angular'
], (ng) ->
  'use strict'

  angular.module('diplomacyServices', [])
    .factory('wsService', ["$q", "$rootScope", ($q, $rootScope) ->
      console.debug "Initializing wsService"

      Service = 
        'connected': false
        'managed_lists': {}

      ws = new WebSocket "ws:localhost:8080/ws?email=unfortunate42%40gmail.com"

      ws.onopen = ->
        console.debug "Socket has been opened!"
        Service.connected = true

      ws.onmessage = (message) ->
        handleData JSON.parse(message.data)

      handleData = (data) ->
        messageObj = data

        console.debug "Received data from websocket: ", messageObj

        if Service.connected
          uri = data['Object']['URI']
          list = Service.managed_lists[uri]

          console.log "Applying message to list #{uri}"

          if data['Type'] == 'Create' or data['Type'] == 'Fetch'
            $rootScope.$apply ->
              for item in data['Object']['Data']
                list[item['Id']] = item

          if data['Type'] == 'Delete'
            $rootScope.$apply ->
              for deleted_object in data['Object']['Data']
                delete list[deleted_object['Id']]

        else
          console.warn 'Service not connected yet, message ignored'

      Service.ws = ws

      Service.registerList = (name, list) ->
        console.debug("Adding list for #{name} (#{list})")
        this.managed_lists[name] = list

      Service.send = (message) ->
        counter = 0
        timeoutId = null

        sendInner = ->
          if this.connected
            console.debug "Sending message"
            this.ws.send(message)

            console.debug "Sent message, stopping"
            clearTimeout(timeoutId)
          else
            timeoutId = setTimeout =>
              counter += 1
              console.debug "Tried #{counter} times"
              if counter >= 50
                console.debug "Failed, stopping"
                clearTimeout(timeoutId)
              else
                sendInner.bind(this, message)()
            , 10

        sendInner.bind(this)()

      Service.subscribeToGames = ->
        defer = $q.defer()

        console.log "Subscribing"
        message =
          "Type": "Subscribe"
          "Object":
            "URI": "/games/current"

        this.send(JSON.stringify(message))
        promise = defer

        return defer.promise

      Service
    ])
    .factory('GameListService', ['wsService', (wsService) ->
        Service =
          gameList: {}

        wsService.registerList("/games/current", Service.gameList)

        Service.get = ->
          # TODO return a sorted list instead
          wsService.subscribeToGames()
          this.gameList

        Service
    ])
)
