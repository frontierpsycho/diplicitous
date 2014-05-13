define([
  'coffee/objects/Order'
  'underscore'
], (
  Order
  _
) ->
  'use strict'

  describe "Order", ->
    describe "fromDiplicity", ->

      it("Should correctly read a move ", ->
        diplicity_order = [
          "Move"
          "war"
        ]

        converted = Order("mos", diplicity_order)

        expect(_.pick(converted, "type", "unit_area", "dst"))
          .toEqual(
            type: "Move"
            unit_area: "mos"
            dst: "war"
          )
      )
)
