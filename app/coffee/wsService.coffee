define([
  'angular'
  'underscore'
], (
  angular
  _
) ->
  'use strict'

  angular.module('diplomacyServices', [])
    .factory('wsService', ["$q", "$rootScope", ($q, $rootScope) ->
      console.debug "Initializing wsService"

      Service =
        'connected': false
        'subscriptions': {}

      ws = new WebSocket "ws:localhost:8080/ws?email=unfortunate42%40gmail.com"

      ws.onopen = ->
        console.debug "Socket opened"
        Service.connected = true

      ws.onmessage = (message) ->
        handleData JSON.parse(message.data)

      handleData = (data) ->
        console.debug "Received data from websocket: ", data

        if Service.connected
          uri = data['Object']['URI']
          subscription = Service.subscriptions[uri]

          unless subscription?
            return

          console.log "Applying data to subscription #{uri}"

          if data['Type'] == 'Create' or data['Type'] == 'Fetch' or data['Type'] == "Update"
            $rootScope.$apply ->
              containedData = data['Object']['Data']

              # transform data with subscription callback
              if subscription.callback?
                containedData = subscription.callback(containedData)

              subscription.target[subscription.name] = containedData

          if data['Type'] == 'Delete'
            $rootScope.$apply ->
              for deleted_object in data['Object']['Data']
                # FIXME
                delete subscription.target[subscription.name][deleted_object['Id']]

        else
          console.warn 'Service not connected yet, message ignored'

      Service.ws = ws

      Service.send = (message) ->
        counter = 0
        timeoutId = null

        sendInner = ->
          if this.connected
            console.debug "Sending message"
            this.ws.send(message)

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

      Service.subscribe = (uri, subscription) ->
        console.log "Subscribing to #{uri}"
        message =
          "Type": "Subscribe"
          "Object":
            "URI": uri

        this.subscriptions[uri] = subscription
        this.send(JSON.stringify(message))

      Service
    ])
)
