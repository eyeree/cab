class_name HexIndex extends RefCounted

# https://www.redblobgames.com/grids/hexagons/

enum HexDirection { NW = 0, NE = 1, E = 2, SE = 3, SW = 4, W = 5 }

static var INVALID:HexIndex = HexIndex.new(2147483647, 2147483647, 2147483647)
static var CENTER:HexIndex = HexIndex.new(0, 0, 0)
    
static var _direction_vectors = [
    HexIndex.new(+1, 0, -1), HexIndex.new(+1, -1, 0), HexIndex.new(0, -1, +1), 
    HexIndex.new(-1, 0, +1), HexIndex.new(-1, +1, 0), HexIndex.new(0, +1, -1), 
]

static func from_axial(q_:int, r_:int) -> HexIndex:
    return HexIndex.new(q_, r_, -q_ - r_)
    
static func from_point(point:Vector2, hex_outer_radius:float) -> HexIndex:
    # pixel_to_pointy_hex https://www.redblobgames.com/grids/hexagons/#pixel-to-hex	
    var q_:float = (sqrt(3)/3 * point.x  -  1.0/3.0 * point.y) / hex_outer_radius
    var r_:float = (2.0/3.0 * point.y) / hex_outer_radius
    return HexIndex.round_axial(q_, r_)
    
static func round_axial(q_:float, r_:float) -> HexIndex:
    return round_cube(q_, r_, -q_ - r_)

static func round_cube(q_:float, r_:float, s_:float) -> HexIndex:
    var q_round = round(q_)
    var r_round = round(r_)
    var s_round = round(s_)

    var q_diff = abs(q_round - q_)
    var r_diff = abs(r_round - r_)
    var s_diff = abs(s_round - s_)

    if q_diff > r_diff and q_diff > s_diff:
        q_round = -r_ - s_
    elif r_diff > s_diff:
        r_round = -q_ - s_
    else:
        s_round = -q_ - r_

    return HexIndex.new(q_round, r_round, s_round)
        
var key:Vector3i

var q:int:
    get():
        return key.x
    set(value):
        key.x = value

var r:int:
    get():
        return key.y
    set(value):
        key.y = value

var s:int:
    get():
        return key.z
    set(value):
        key.z = value

func _init(q_:int, r_:int, s_:int):
    key = Vector3i(q_, r_, s_)
    
func add(index:HexIndex) -> HexIndex:
    return HexIndex.new(q + index.q, r + index.r, s + index.s)

func subtract(index:HexIndex) -> HexIndex:
    return HexIndex.new(q - index.q, r - index.r, s - index.s)
    
func scale(factor:int) -> HexIndex:
    return HexIndex.new(q * factor, r * factor, s * factor)
    
func neighbor(direction:HexDirection) -> HexIndex:
    return add(_direction_vectors[direction])   
    
func distance_to(index:HexIndex) -> int:
    var difference:HexIndex = subtract(index)
    return (abs(difference.q) + abs(difference.r) + abs(difference.s)) / 2

func distance_to_center() -> int:
    return (abs(q) + abs(r) + abs(s)) / 2
    
func ring(radius:int) -> Array[HexIndex]:
    var results:Array[HexIndex] = []
    var index = add(_direction_vectors[4].scale(radius))
    for direction in HexDirection:
        for hex in range(0, radius):
            results.append(index)
            index = index.neighbor(direction)
    return results	

func to_axial() -> Vector2i:
    return Vector2i(q, r)	
    
func center_point(hex_outer_radius:float) -> Vector2:
    # pointy_hex_to_pixel https://www.redblobgames.com/grids/hexagons/#hex-to-pixel-axial
    var x:float = hex_outer_radius * (sqrt(3) * q  +  sqrt(3)/2 * r)
    var y:float = hex_outer_radius * (3.0/2.0 * q)
    return Vector2(x, y)

                    
        
