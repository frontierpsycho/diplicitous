define([
  'drawing'
  'lodash'
], (
  Drawing
  _
) ->
  'use strict'


  describe "Drawing", ->
    describe "Vector", ->
      Vector = Drawing.Vector

      describe "add", ->
        it "should correctly add unit vectors", ->
          diagonal = (new Vector(1, 0)).add(new Vector(0, 1))

          expect(diagonal.x).toEqual(1)
          expect(diagonal.y).toEqual(1)

        it "should correctly add negative unit vectors", ->
          zero = (new Vector(1, 1)).add(new Vector(-1, -1))

          expect(zero.x).toEqual(0)
          expect(zero.y).toEqual(0)

      describe "fromPolar", ->
        it "should correctly construct the unit diagonal vector", ->
          diagonal = new Vector.fromPolar(Math.sqrt(2), Math.PI / 4)

          expect(diagonal.x).toBeCloseTo(1, 2)
          expect(diagonal.y).toBeCloseTo(1, 2)

        it "should correctly construct an equilateral triangle's side", ->
          vector = new Vector.fromPolar(1, Math.PI * 2 / 6)

          expect(vector.x).toBeCloseTo(1/2, 1)
          expect(vector.y).toBeCloseTo(Math.sqrt(3) / 2, 1)

      describe "angle", ->
        it "should be 45 degrees on the unit square's diagonal", ->
          diagonal = new Vector(1, 1)

          expect(diagonal.angle()).toBeCloseTo(Math.PI/4, 1)

        it "should be 60 degrees on the left side of an equilateral triangle", ->
          vector = new Vector(0.5, Math.sqrt(3)/2)

          expect(vector.angle()).toBeCloseTo(Math.PI/3, 1)
)

