import std/math

type 
    Vec2 = object
        x, y : float

    Plane = object 
        x,y,c : float

proc vec2(x, y : float) : Vec2 = Vec2(x: x,y: y)

proc plane(x, y, c: float) : Plane = Plane(x: x, y: y, c: c)

proc add(v1, v2: Vec2) : Vec2 = vec2(v1.x + v2.x, v1.y + v2.y)

proc sub(v1, v2: Vec2) : Vec2 = vec2(v1.x - v2.x, v1.y - v2.y)

proc mult(v: Vec2, s: float) : Vec2 = vec2(v.x * s, v.y * s)

proc dot(v1, v2: Vec2) : float = v1.x * v2.x + v1.y * v2.y

proc cross(v1, v2: Vec2) : Vec2 = vec2(v1.x * v2.y,  v1.y * v2.x)

proc length(v1: Vec2) : float = sqrt(v1.x * v1.x + v1.y * v1.y)

proc lengthsqr(v1: Vec2) : float = v1.x * v1.x + v1.y * v1.y

proc norm(v1: Vec2) : Vec2 = 
    let length = length(v1)
    vec2(v1.x / length, v1.y / length)

proc plane(normV, point: Vec2) : Plane = 
    let c = - (normV.x * point.x + normV.y * point.y)
    return plane(normV.x, normV.y, c)

proc mirowRay(p: Plane, v: Vec2) : Vec2 =
    let projc = dot(v, vec2(p.x, p.y))/dot(vec2(p.x, p.y), vec2(p.x, p.y))
    let projn = mult(vec2(p.x, p.y), projc)

    let newV = sub(v, mult(projn, 2))
    return newV

proc rotVec2(v: Vec2, a: float) : Vec2 = 
    let 
        cosres = cos(a)
        sinres = sin(a)

        resx = v.x * cosres - v.y * sinres
        resy = v.x * sinres + v.y * cosres
    
    vec2(resx, resy)


# tests
proc test1() = 
    let p = plane(vec2(1,0), vec2(0,1))
    let v = vec2(-0.1, 1)

    let mv = mirowRay(p, v)

    echo mv.x
    echo mv.y

proc test2() = 
    let v = vec2(1,0)

    let v2 = rotVec2(v, PI/2)

    echo v2.x
    echo v2.y
