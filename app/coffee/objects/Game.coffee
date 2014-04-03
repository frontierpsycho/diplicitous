define([
  'underscore'
], (
  _
) ->
  'use strict'

  Game = (game) ->
    game.player = (user) ->
      _.find(this.Members, (mem) -> mem.User.Email == user.Email)

    game.units = (user) ->
      player = this.player(user)
      units = _.filter(_.pairs(this.Phase.Units), (pair) -> pair[1].Nation == player.Nation )

    return game
)
