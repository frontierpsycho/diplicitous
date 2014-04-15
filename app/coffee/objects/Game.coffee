define([
  'underscore'
], (
  _
) ->
  'use strict'

  Game = (game) ->
    game.player = (user) ->
      _.find(this.Members, (mem) -> mem.User.Email == user.Email)

    game.units = (abbrList) ->
      _.filter(_.pairs(this.Phase.Units), (pair) -> pair[0] in abbrList )

    return game

  Game
)
