define([
  'angular'
  'directives/directives'
  'underscore'
], (
  angular
  directives
  _
) ->
  'use strict'

  angular.module('diplomacyDirectives')
    .directive('dipPowers', ->
      {
        templateUrl: 'templates/dipPowers.html'
        replace: true
        restrict: 'E'
        link: ($scope, iElem, iAttr) ->
          $scope.$watch('game', (game, oldValue) ->
            if game?
              powers = _.clone(game.Members)
              console.debug("Powers: #{powers}")
              powers = _.chain(powers)
                .map((power) -> {
                  power: power,
                  scs: game.supplyCenters(power.Nation).length
                  units: game.units(power.Nation).length
                })
                .sortBy((pair) -> pair.scs)
                .reverse()
                .value()

              maxSCs = powers[0].scs
              powers.map((data) -> data.percent = Math.round(((data.scs / maxSCs) * 100)).toFixed(0))
              $scope.powers = powers

              $scope.textSign = (number) ->
                if number > 0
                  return "+"
                else if number < 0
                  return "-"
                else
                  return ""

              $scope.deltaClass = (number) ->
                if number > 0
                  return "plus"
                else if number < 0
                  return "minus"
                else
                  return ""
          )
      }
    )
)
