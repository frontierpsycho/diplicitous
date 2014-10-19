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

    # returns the units of the given power
    game.units = (power) ->
      _.filter(this.Phase.Units, (unit) -> unit.Nation == power)

    # returns a power's supply centers
    game.supplyCenters = (power) ->
      _.filter(_.pairs(this.Phase.SupplyCenters), (pair) -> pair[1] == power)

    return game

  Game
)
