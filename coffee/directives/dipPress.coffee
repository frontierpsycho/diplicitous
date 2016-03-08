define([
  'angular'
  'directives/directives'
  'lodash'
], (
  angular
  directives
  _
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('dipPress', ['wsService', (wsService) ->
      {
        templateUrl: 'templates/press/press.html'
        replace: true
        restrict: 'E'
        link: ($scope, iElem, iAttr) ->
          $scope.sendPress = ->
            console.log('Send press', iElem.find('input#press').val())
            message = {
              URI: "/games/#{$scope.game.Id}/messages"
              Data:
                Body: iElem.find('input#press').val()
                GameId: $scope.game.Id
                RecipientIds: _.reduce($scope.game.Members, ((acc, member) -> acc[member.Id] = true; return acc), {})
                SenderId: $scope.user.Id
                Public: false
                SeenBy: {}
            }
            console.log(message)
            wsService.sendCreate(message)
      }
    ])
    .directive('dipMessage', ->
      {
        templateUrl: 'templates/press/message.html'
        replace: true
        restrict: 'E'
        scope:
          message: "="
      }
    )
)
