define( ->
  'use strict'

  that = {}

  sqrt3 = Math.sqrt(3)

  class Vector
    constructor: (@x, @y) ->

    @fromPolar: (mag, r) ->
      new Vector(mag * Math.cos(r), mag * Math.sin(r))

    @fromPoints: (pointA, pointB) ->
      new Vector(pointB.x - pointA.x, pointB.y - pointA.y)

    magnitude: -> Math.sqrt(@x * @x + @y * @y)
    angle: -> Math.atan2(@y, @x)
    fraction: (r) -> new Vector(r * @x, r * @y)
    withMagnitude: (magnitude) -> Vector.fromPolar(magnitude, this.angle())
    perpendicular: (magnitude) ->
      magnitude = magnitude || this.magnitude()
      Vector.fromPolar(magnitude, Math.atan2(-@x, @y))
    opposite: -> new Vector(-@x, -@y)

    add: (point) -> new Vector(@x + point.x, @y + point.y)

    toString: -> "#{@x},#{@y}"

  that.orthogonal = (pointA, pointB, magnitude) ->
    midpoint = new Vector( (pointA.x + pointB.x)/2, (pointA.y + pointB.y)/2 )

    # vector orthogonal to AB
    Vector.fromPolar(magnitude, - Math.atan2(midpoint.x - pointA.x, midpoint.y - pointA.y))

  that.arrowPath = (pointA, pointB, suffix = "M") ->
    [startLeft, midLeft, endLeft, arrowLeft, arrowTip, arrowRight, endRight, midRight, startRight] = that.arrow(pointA, pointB)
    [
      "#{suffix}#{startLeft.toString()}"
      "Q#{midLeft.toString()}"
      endLeft.toString()
      "L#{arrowLeft.toString()}"
      "L#{arrowTip.toString()}"
      "L#{arrowRight.toString()}"
      "L#{endRight.toString()}"
      "Q#{midRight.toString()}"
      startRight.toString()
      "Z"
    ]

  that.arrow = (pointA, pointB) ->
    arrowHalfWidth = 5
    midpoint = new Vector( (pointA.x + pointB.x)/2, (pointA.y + pointB.y)/2 )
    ab = Vector.fromPoints(pointA, pointB)
    orthogonal = ab.perpendicular((ab.magnitude() * sqrt3 / 4))
    orthogonalDelta = ab.perpendicular(arrowHalfWidth)

    pointC = midpoint.add(orthogonal)

    ac = Vector.fromPoints(pointA, pointC)
    bc = Vector.fromPoints(pointB, pointC)

    pStart = pointA.add(ac.withMagnitude(20))
    pEnd = pointB.add(bc.withMagnitude(40))

    pMidLeft = midpoint.add(orthogonal).add(orthogonalDelta)
    pMidRight = midpoint.add(orthogonal).add(orthogonalDelta.opposite())

    pStartLeft = pStart.add(ac.perpendicular(arrowHalfWidth))
    pEndLeft = pEnd.add(bc.perpendicular(arrowHalfWidth).opposite())

    pEndRight = pEnd.add(bc.perpendicular(arrowHalfWidth))
    pStartRight = pStart.add(ac.perpendicular(arrowHalfWidth).opposite())

    arrowLeft = pEndLeft.add(bc.perpendicular(arrowHalfWidth).opposite())
    arrowTip = pointB.add(bc.withMagnitude(20))
    arrowRight = pEndRight.add(bc.perpendicular(arrowHalfWidth))

    [pStartLeft, pMidLeft, pEndLeft, arrowLeft, arrowTip, arrowRight, pEndRight, pMidRight, pStartRight]

  that.Vector = Vector
  that.Point = Vector # Point is an alias for Vector

  that
)
