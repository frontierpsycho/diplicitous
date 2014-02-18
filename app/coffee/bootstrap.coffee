define([
  'require'
  'angular'
  'app'
], (
  require
  angular
) ->
    'use strict'

    require(['domReady!'], (document) ->
        angular.bootstrap(document, ['diplomacy'])
    )
)
