define([
  'angular'
  'config'
  'directives/directives'
], (
  angular
  Config
  directives
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('menu', ['UserService', (UserService) ->
      {
        templateUrl: 'templates/menu.html'
        replace: true
        restrict: 'E'
        scope: {}
        link: ($scope, iElem, iAttr) ->
          $scope.oauthHost = Config.wsHost
          $scope.return_to = encodeURIComponent(document.URL)

          $scope.loggedIn = ->
            not _.isEmpty(UserService.user.Email)

          $scope.loaded = -> UserService.loaded

          $scope.$watch((-> UserService.loaded), (loaded) ->
            if loaded
              console.debug('User', UserService.user)
              unless _.isEmpty(UserService.user)
                console.debug('User service loaded')
                $scope.user = UserService.user
              else
                $scope.user = false
          )
      }
    ])

)
