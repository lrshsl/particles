import nimraylib_now

# startsection Consts
const
  Factor = 0.01
  AirDrag = 0.01
  BodyRadius = 50.0
  MaxSpeed = 40.0
  MaxAcceleration = 0.5

# endsection Consts

# startsection Vector helpers
type
  IVec2 = object
    x, y: cint

func vec2(x, y: cfloat): Vector2 = Vector2(x: x, y: y)
func ivec2(x, y: cint): IVec2 = IVec2(x: x, y: y)

func getScreenSize(): IVec2 =
  ivec2(getScreenWidth(), getScreenHeight())

func asVec2(v: IVec2): Vector2 = vec2(v.x.cfloat, v.y.cfloat)

# endsection

# startsection Body
type
  Body = object
    pos, vel, acc: Vector2

#proc collide(a, b: Body) = nil

proc reflectFromWalls(body: var Body, bounds: Rectangle) =
  if body.pos.x - BodyRadius < bounds.x:
    body.vel.x = abs(body.vel.x)
  elif body.pos.x + BodyRadius > bounds.width:
    body.vel.x = -abs(body.vel.x)
  if body.pos.y - BodyRadius < bounds.y:
    body.vel.y = abs(body.vel.y)
  elif body.pos.y + BodyRadius > bounds.height:
    body.vel.y = -abs(body.vel.y)

# endsection

let
  Gravity = vec2(0, 9.81) * Factor

proc run*() =
  initWindow(800, 800, "Particles")
  setTargetFPS(60)

  var
    body = Body(
        pos: getScreenSize().asVec2 * 0.5,
        vel: vector2Zero(),
        acc: vector2Zero(),
        )
    is_dragging = false

  while not (isKeyDown(Q) or windowShouldClose()):

    if isMouseButtonPressed(MouseButton.LEFT) and getMousePosition().checkCollisionPointCircle(body.pos, BodyRadius):
      is_dragging = true
    if isMouseButtonReleased(MouseButton.LEFT):
      is_dragging = false

    if is_dragging:
      body.vel = (getMousePosition() - body.pos).clampValue(0, MaxSpeed)

    body.acc = Gravity - (body.vel * AirDrag).clampValue(0, MaxAcceleration)
    body.vel = (body.vel + body.acc).clampValue(0, MaxSpeed)
    body.pos += body.vel
    body.reflectFromWalls(Rectangle(x: 0, y: 0, width: getScreenWidth().cfloat, height: getScreenHeight().cfloat))

    beginDrawing:
      clearBackground(Black)
      drawCircleLines(body.pos.x.cint, body.pos.y.cint, BodyRadius, Green)
      drawFPS(0, 0)


# vim: fmr=startsection,endsection
