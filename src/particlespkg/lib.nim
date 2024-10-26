import math

from nimraylib_now import getScreenWidth, getScreenHeight, drawCircleLines, beginDrawing, clearBackground, Black, Color,
  isMouseButtonPressed, isMouseButtonDown, MouseButton, getMousePosition, checkCollisionPointCircle,
  clamp, clampValue, drawFPS, initWindow, setTargetFPS, windowShouldClose, isKeyDown, KeyboardKey

import std/[sugar, sequtils, random]

# startsection Consts
const
  Factor = 0.01
  AirDrag = 0.01
  RadiusRange = 10.0..50.0
  MaxSpeed = 40.0
  MaxAcceleration = 0.5
  NumberParticles = 10

# endsection Consts

# startsection Vector helpers
type
  IVec2 = object
    x, y: cint

func ivec2(x, y: cint): IVec2 = IVec2(x: x, y: y)

func getScreenSize(): IVec2 =
  ivec2(getScreenWidth(), getScreenHeight())

func asVec2(v: IVec2): Vec2 = vec2(v.x.cfloat, v.y.cfloat)

# endsection

# startsection Body
type
  Body = object
    pos, vel, acc: Vec2
    radius: float
    mass: float
    color: Color
    is_being_dragged: bool
 # endsection

 # startsection Collision detection
proc collide(a, b: var Body) =
  # Check for collision using squared distance to avoid unnecessary calculations
  if (a.pos - b.pos).lengthSqr >= ((a.radius + b.radius) * (a.radius + b.radius)):
    return

  # step back (--> not intersecting anymore)
  a.pos -= a.vel
  b.pos -= b.vel

  # Calculate the normal and tangent vectors
  let
    collision_axis = (b.pos - a.pos).norm
    tangent_axis = collision_axis.rotate(90)

  # Project velocities onto the normal and tangent vectors
  let
    a_normal_vel = a.vel.dot(collision_axis)
    b_normal_vel = b.vel.dot(collision_axis)
    a_tangent_vel = a.vel.dot(tangent_axis)
    b_tangent_vel = b.vel.dot(tangent_axis)

  # Conservation of momentum for normal components (elastic collision)
  let
    a_mass = a.mass
    b_mass = b.mass
    a_normal_vel_after = (a_normal_vel * (a_mass - b_mass) + 2 * b_mass *
        b_normal_vel) / (a_mass + b_mass)
    b_normal_vel_after = (b_normal_vel * (b_mass - a_mass) + 2 * a_mass *
        a_normal_vel) / (a_mass + b_mass)

  # Tangent velocities remain unchanged in a perfectly elastic collision
  a.vel = tangent_axis * a_tangent_vel + collision_axis * a_normal_vel_after
  b.vel = tangent_axis * b_tangent_vel + collision_axis * b_normal_vel_after


proc reflectFromWalls(body: var Body, bounds_min, bounds_max: Vec2) =
  if body.pos.x < bounds_min.x:
    body.vel.x = abs(body.vel.x)
  elif body.pos.x > bounds_max.x:
    body.vel.x = -abs(body.vel.x)
  if body.pos.y < bounds_min.y:
    body.vel.y = abs(body.vel.y)
  elif body.pos.y > bounds_max.y:
    body.vel.y = -abs(body.vel.y)
# endsection

let
  Gravity = vec2(0, 9.81) * Factor

proc process(bodies: var seq[Body], body: var Body) =
  if isMouseButtonPressed(MouseButton.LEFT.cint) and getMousePosition().checkCollisionPointCircle(body.pos.raylib, body.radius):
    body.is_being_dragged = true
  if not isMouseButtonDown(MouseButton.LEFT.cint):
    body.is_being_dragged = false

  if body.is_being_dragged:
    body.vel = (getMousePosition().vec2 - body.pos).raylib.clampValue(0.0, MaxSpeed).vec2

  let
    screen_bounds_min = vec2(body.radius, body.radius)
    screen_bounds_max = (getScreenSize().asVec2 - vec2(body.radius, body.radius))

  body.acc = (Gravity - (body.vel * AirDrag)).raylib.clampValue(0, MaxAcceleration).vec2
  body.vel = (body.vel + body.acc).raylib.clampValue(0, MaxSpeed).vec2
  body.pos += body.vel

  # Interactions
  body.reflectFromWalls(screen_bounds_min, screen_bounds_max)
  for other in bodies.mitems:
    if other != body:
      body.collide(other)

  body.pos = body.pos.raylib.clamp(screen_bounds_min.raylib, screen_bounds_max.raylib).vec2

proc draw(body: Body) =
  clearBackground(Black)
  drawCircleLines(body.pos.x.cint, body.pos.y.cint, body.radius, body.color)
  drawFPS(0, 0)

proc randomColor(): Color =
  Color(
      r: rand(100..255).uint8,
      g: rand(100..255).uint8,
      b: rand(100..255).uint8,
      a: 255
  )

proc generateBody(): Body =
  let r = rand(RadiusRange)
  result.radius = r
  result.pos = ivec2(
        rand(r.cint..(getScreenWidth() - r.cint)),
        rand(r.cint..(getScreenHeight() - r.cint))
  ).asVec2
  result.vel = vec2(0, 0)
  result.acc = vec2(0, 0)
  result.mass = r
  result.color = randomColor()
  result.is_being_dragged = false

proc run*() =
  initWindow(800, 800, "Particles")
  setTargetFPS(60)

  var
    bodies = collect(newSeq):
      for _ in 0..<NumberParticles:
        generateBody()

  while not (isKeyDown(Q.cint) or windowShouldClose()):

    bodies.apply((body: var Body) => process(bodies, body))

    beginDrawing:
      bodies.apply(draw)

# vim: fmr=startsection,endsection
