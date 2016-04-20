define([
  'angular'
  'lodash'
  'config'
], (
  angular
  _
  Config
) ->
  'use strict'

  angular.module('diplomacyServices', [])
    .factory('wsService', [
      "$q"
      "$rootScope"
      "TokenService"
      ($q, $rootScope, TokenService) ->
        Service =
          connected: false
          subscriptions: {}

        initRetries = 0

        Service.initWebSocket = (wsURL) ->
          ws = new WebSocket wsURL

          ws.onopen = ->
            console.debug "Socket opened", this.readyState
            $rootScope.$apply ->
              initRetries = 0
              Service.connected = true

          ws.onclose = ->
            console.debug "Socket closed"
            $rootScope.$apply ->
              Service.connected = false

          ws.onerror = (err) ->
            console.debug "Socket closed because of error", err
            $rootScope.$apply ->
              Service.connected = false
              # TODO meh, could be better.
              initRetries += 1
              if initRetries < 10
                setTimeout((-> TokenService.refresh()), 50)
              else
                console.warn("Tried to reconnect 10 times, stopping")

          ws.onmessage = (message) ->
            data = JSON.parse(message.data)

            if data.Type?
              switch data.Type
                when 'RPC'
                  Service.handleRPC data
                when 'Error'
                  Service.handleError data
                else
                  Service.handleData data

          this.ws = ws
          return ws

        Service.handleData = (data) ->
          console.debug "Received data from websocket: ", data

          if Service.connected
            uri = data['Object']['URI']
            subscription = Service.subscriptions[uri]

            unless subscription?
              return

            console.log "Applying data to subscription #{uri}"

            type = data['Type']

            switch type
              when 'Create'
                $rootScope.$apply ->
                  containedData = data['Object']['Data']

                  _.each(containedData, (dataPoint) ->
                    # transform data with subscription callback
                    if subscription.callback?
                      dataPoint = subscription.callback(dataPoint)

                    subscription.target[subscription.name].push(dataPoint)
                  )
              when 'Fetch', 'Update' # TODO should probably separate those
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

        Service.handleError = (data) ->
          error = data.Error

          console.error "Received error from websocket:", error.Error

          switch error.Cause.Type
            when 'RPC'
              id = error.Cause.Method.Id
            else
              id = error.Cause.Object.URI

          if id? and Service.subscriptions.hasOwnProperty(id)
            delete Service.subscriptions[id]

        Service.handleRPC = (data) ->
          console.debug "Received RPC result from websocket:", data

          if Service.connected
            method = data.Method

            callback = Service.subscriptions[method.Id]

            if callback?
              console.debug "Running callback"
              callback()
              delete Service.subscriptions[method.Id]
          else
            console.warn 'Service not connected yet, message ignored'

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

          this.subscriptions[uri] = subscription
          this.send(JSON.stringify({
            Type: "Subscribe"
            Object:
              URI: uri
          }))

        Service.sendCreate = (data) ->
          this.send(JSON.stringify({
            Type: "Create"
            Object: data
          }))

        Service.sendRPC = (method, data, callback) ->
          randomId = Math.random().toString(36).substring(2)

          this.subscriptions[randomId] = callback
          this.send(JSON.stringify({
            Type: "RPC"
            Method:
              Name: method
              Id: randomId
              Data: data
          }))


        $rootScope.$watch((-> TokenService.loaded), (newValue, oldValue) ->
          console.debug("Token watch", newValue, oldValue)
          if newValue
            wsURL = "ws:#{Config.wsHost}/ws"
            if TokenService.token()
              wsURL += "?token=#{TokenService.token()}"

            console.debug "Initializing wsService #{wsURL}"
            Service.initWebSocket(wsURL)
        )

        Service
    ])
)
