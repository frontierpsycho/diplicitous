define([
  'underscore'
], (
  _
) ->
  'use strict'

  # Wrap the diplicity Game object to implement some convenience functions
  Game = (game) ->
    # returns the current logged in player, or undefined if there is none
    game.player = (user) ->
      _.find(this.Members, (mem) -> mem.User.Email == user.Email)

    # returns the units of the given provinces
    game.units = (abbrList) ->
      _.filter(_.pairs(this.Phase.Units), (pair) -> pair[0] in abbrList )

    return game

  Game
)
