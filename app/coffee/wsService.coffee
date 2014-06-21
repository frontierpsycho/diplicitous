define([
  'angular'
  'underscore'
  'config'
], (
  angular
  _
  Config
) ->
  'use strict'

  angular.module('diplomacyServices', [])
    .factory('wsService', ["$q", "$rootScope", ($q, $rootScope) ->
      console.debug "Initializing wsService"

      Service =
        'connected': false
        'subscriptions': {}

      ws = new WebSocket "ws:#{Config.wsHost}/ws?email=#{Config.email}"

      ws.onopen = ->
        console.debug "Socket opened"
        Service.connected = true

      ws.onmessage = (message) ->
        data = JSON.parse(message.data)

        if data.Type?
          if data.Type == "RPC"
            handleRPC data
          else
            handleData data

      handleData = (data) ->
        console.debug "Received data from websocket: ", data

        if Service.connected
          uri = data['Object']['URI']
          subscription = Service.subscriptions[uri]

          unless subscription?
            return

          console.log "Applying data to subscription #{uri}"

          type = data['Type']

          switch type
            when 'Create', 'Fetch', 'Update'
              $rootScope.$apply ->
                containedData = data['Object']['Data']

                # transform data with subscription callback
                if subscription.callback?
                  containedData = subscription.callback(containedData)

                subscription.target[subscription.name] = containedData
            when 'Delete'
              $rootScope.$apply ->
                for deleted_object in data['Object']['Data']
                  # FIXME
                  delete subscription.target[subscription.name][deleted_object['Id']]
        else
          console.warn 'Service not connected yet, message ignored'

      handleRPC = (data) ->
        console.debug "RPC!"

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

      Service.sendRPC = (method, data) ->
        this.send(JSON.stringify({
          Type: "RPC"
          Method:
            Name: method
            Id: Math.random().toString(36).substring(2)
            Data: data
        }))

      Service
    ])
)
