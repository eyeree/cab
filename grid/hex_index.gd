class_name HexIndex extends RefCounted

# https://www.redblobgames.com/grids/hexagons/

enum HexDirection { NE = 0, E = 1, SE = 2, SW = 3, W = 4, NW = 5 }

static var INVALID:HexIndex = HexIndex.new(2147483647, 2147483647, 2147483647)
static var CENTER:HexIndex = HexIndex.new(0, 0, 0)
    
static var _direction_vectors = [
    HexIndex.new(+1, -1, 0), # NE
    HexIndex.new(+1, 0, -1), # E
    HexIndex.new(0, +1, -1), # SE
    HexIndex.new(-1, +1, 0), # SW
    HexIndex.new(-1, 0, +1), # W
    HexIndex.new(0, -1, +1), # NW
]

static func from_axial(q_:int, r_:int) -> HexIndex:
    return HexIndex.new(q_, r_, -q_ - r_)
    
static var last:HexIndex = HexIndex.INVALID

static func from_point(point:Vector2, hex_outer_radius:float) -> HexIndex:
    # pixel_to_pointy_hex https://www.redblobgames.com/grids/hexagons/#pixel-to-hex	
    var q_:float = ((sqrt(3.0)/3.0) * point.x  -  (1.0/3.0) * point.y) / hex_outer_radius
    var r_:float = ((2.0/3.0) * point.y) / hex_outer_radius
    return HexIndex.round_axial(q_, r_)
    
static func round_axial(q_:float, r_:float) -> HexIndex:
    var q_round:int = roundi(q_)
    var r_round:int = roundi(r_)
    q_ -= q_round 
    r_ -= r_round
    if abs(q_) >= abs(r_):
        return HexIndex.from_axial(q_round + roundi(q_ + 0.5*r_), r_round)
    else:
        return HexIndex.from_axial(q_round, r_round + roundi(r_ + 0.5*q_))

static func round_cube(q_:float, r_:float, s_:float) -> HexIndex:
    var q_round:int = roundi(q_)
    var r_round:int = roundi(r_)
    var s_round:int = roundi(s_)

    var q_diff:float = abs(q_round - q_)
    var r_diff:float = abs(r_round - r_)
    var s_diff:float = abs(s_round - s_)

    if q_diff > r_diff and q_diff > s_diff:
        q_round = -r_round - s_round
    elif r_diff > s_diff:
        r_round = -q_round - s_round
    else:
        s_round = -q_round - r_round

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
    for direction in HexDirection.values():
        for hex in range(0, radius):
            results.append(index)
            index = index.neighbor(direction)
    return results	

func to_axial() -> Vector2i:
    return Vector2i(q, r)	
    
func center_point(hex_outer_radius:float) -> Vector2:
    # pointy_hex_to_pixel https://www.redblobgames.com/grids/hexagons/#hex-to-pixel-axial
    var x:float = hex_outer_radius * (sqrt(3.0) * q  +  sqrt(3.0)/2.0 * r)
    var y:float = hex_outer_radius * ((3.0/2.0) * r)
    return Vector2(x, y)

        
func _to_string() -> String:
    return "{q: %d, r: %d, s: %d}" % [q, r, s]