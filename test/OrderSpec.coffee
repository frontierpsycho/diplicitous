define([
  'models/Order'
  'lodash'
], (
  Order
  _
) ->
  'use strict'

  describe "Order", ->
    describe "fromDiplicity", ->

      it "should correctly read a move", ->
        diplicity_order = [
          "Move"
          "war"
        ]

        converted = Order("Russia", "mos", diplicity_order)

        expect(_.pick(converted, "type", "unit_area", "dst"))
          .toEqual(
            type: "Move"
            unit_area: "mos"
            dst: "war"
          )

      it "should correctly read a support", ->
        diplicity_order = [
          "Support"
          "gal"
          "war"
        ]

        converted = Order("Russia", "mos", diplicity_order)

        expect(_.pick(converted, "type", "unit_area", "dst", "src"))
          .toEqual(
            type: "Support"
            unit_area: "mos"
            src: "gal"
            dst: "war"
          )

      it "should return an empty object when fed one", ->
        converted = Order "mos", {}

        expect(_.pick(converted, "type", "unit_area", "dst"))
          .toEqual {}

      it "should return an empty object when fed nothing", ->
        converted = Order "mos"

        expect(_.pick(converted, "type", "unit_area", "dst"))
          .toEqual {}
)
