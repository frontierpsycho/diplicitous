define([
  'angular'
  'services/viewBoxString'
  'lodash'
  'directives/directives'
], (
  angular
  ViewBoxString
  _
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive 'diplomacyMap', ["MapService", (MapService) ->
      return {
        templateUrl: "img/classical.svg"
        replace: true
        restrict: 'E'
        link: {
          pre: (scope, iElement, tAttrs, transclude) ->
            # the map is loaded, init map service
            MapService.init()

            scrolling = false
            moving = false
            scrollStartX = null
            scrollStartY = null

            iElement.on('mousedown', (event) ->
              if scope.zoomed
                scrolling = true
                # TODO jesus, move into MapService already
                vb = new ViewBoxString(MapService.snap.node.getAttribute('viewBox'))
                scrollStartX = vb.x + event.clientX
                scrollStartY = vb.y + event.clientY
                console.log('mousedown!', scrollStartX, scrollStartY)
            )

            iElement.on('mouseleave', (event) ->
              scrolling = false
              moving = false
            )

            iElement.on('mousemove', (event) ->
              if moving
                console.debug("Already moving, return")
                return
              if scrolling
                moving = true

                scrollDiffX = scrollStartX - event.clientX
                scrollDiffY = scrollStartY - event.clientY

                vb = new ViewBoxString(MapService.snap.node.getAttribute('viewBox'))
                MapService.scroll(scrollDiffX, scrollDiffY)

                moving = false
            )

            iElement.on('mouseup', (event) ->
              scrolling = false
              moving = false
              console.log('mouseup!', event.clientX, event.clientY)
            )
        }
      }]
)
