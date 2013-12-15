define([
  'require'
  'angular'
  'app'
], (require, ng) ->
    'use strict'

    require(['domReady!'], (document) ->
        ng.bootstrap(document, ['diplomacy'])
    )
)
