import unittest

import std/math
from nimraylib_now import Vector2

type 
    Vec2* = object
        x*, y* : float

    Plane* = object 
        x*,y*,c* : float

func vec2*(x, y : float) : Vec2 = Vec2(x: x,y: y)
func vec2*(v: Vector2): Vec2 = vec2(v.x, v.y)

func plane*(x, y, c: float) : Plane = Plane(x: x, y: y, c: c)

func `+`*(v1, v2: Vec2) : Vec2 = vec2(v1.x + v2.x, v1.y + v2.y)

func `+=`*(v1: var Vec2, v2: Vec2) =
  v1.x += v2.x
  v1.y += v2.y

func `-`*(v1, v2: Vec2) : Vec2 = vec2(v1.x - v2.x, v1.y - v2.y)
func `-=`*(v1: var Vec2, v2: Vec2) =
  v1.x -= v2.x
  v1.y -= v2.y


func `*`*(v: Vec2, s: float) : Vec2 = vec2(v.x * s, v.y * s)
func `*=`*(v1: var Vec2, v2: Vec2) =
  v1.x *= v2.x
  v1.y *= v2.y


func dot*(v1, v2: Vec2) : float = v1.x * v2.x + v1.y * v2.y

func cross*(v1, v2: Vec2) : Vec2 = vec2(v1.x * v2.y,  v1.y * v2.x)

func length*(v1: Vec2) : float = sqrt(v1.x * v1.x + v1.y * v1.y)

func lengthSqr*(v1: Vec2) : float = v1.x * v1.x + v1.y * v1.y

func norm*(v1: Vec2) : Vec2 = 
    let length = length(v1)
    vec2(v1.x / length, v1.y / length)

func plane*(normV, point: Vec2) : Plane = 
    let c = - (normV.x * point.x + normV.y * point.y)
    return plane(normV.x, normV.y, c)

func mirror*(v: Vec2, p: Plane) : Vec2 =
    let
      v2 = vec2(p.x, p.y)
      projc = v.dot(v2) / v2.dot(v2)
      projn = vec2(p.x, p.y) * projc

    return v - (projn * 2)

func rotate*(v: Vec2, a: float) : Vec2 = 
    let 
        cosres = cos(a)
        sinres = sin(a)

        resx = v.x * cosres - v.y * sinres
        resy = v.x * sinres + v.y * cosres
    
    vec2(resx, resy)

func raylib*(v: Vec2): Vector2 =
  Vector2(x: v.x, y: v.y)


# Tests
suite "Vector Tests":
  test "mirror a vector by a plane":
    let
      p = plane(vec2(1,0), vec2(0,1))
      v = vec2(-0.1, 1)
      mv = v.mirror(p)

    echo mv.x
    echo mv.y

  test "rotating a vector around another vector":
    let
      v = vec2(1,0)
      v2 = v.rotate(PI/2)

    echo v2.x
    echo v2.y

