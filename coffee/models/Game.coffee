define([
  'models/Player'
  'lodash'
  'moment'
], (
  Player
  _
  moment
) ->
  'use strict'

  # Wrap the diplicity Game object to implement some convenience functions
  Game = (game) ->
    # returns the current logged in player, or undefined if there is none
    game.player = (user) ->
      _.find(this.Members, (power) ->
        if power?.User?.Email? and user?.Email?
          power.User.Email == user.Email
        else
          null
      )

    game.membersByEmail = _.reduce(game.Members, (acc, member) ->
      acc[member.User.Email] = Player(member)
      return acc
    , {})

    game.membersById = _.reduce(game.Members, (acc, member) ->
      acc[member.Id] = game.membersByEmail[member.User.Email]
      return acc
    , {})

    # returns the units of the given power
    game.units = (power) ->
      _.filter(this.Phase.Units, (unit) -> unit.Nation == power)

    # returns a power's supply centers
    game.supplyCenters = (power) ->
      _.filter(_.toPairs(this.Phase.SupplyCenters), (pair) -> pair[1] == power)

    # time left until next phase, in seconds
    game.timeLeft = -> Math.floor(game.TimeLeft / 1000000000)

    game.isCurrentPhase = -> game.Phase.Ordinal == game.Phases

    return game

  Game
)
