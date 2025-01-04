class_name HexIndex extends RefCounted

# https://www.redblobgames.com/grids/hexagons/

static var INVALID:HexIndex = HexIndex.from(10000, 10000, 10000)
static var CENTER:HexIndex = HexIndex.from(0, 0, 0)

#region Direction

enum HexDirection { NE = 0, E = 1, SE = 2, SW = 3, W = 4, NW = 5 }

static var ALL_DIRECTIONS:Array[HexDirection] = [
	HexDirection.NE, HexDirection.E, HexDirection.SE, 
	HexDirection.SW, HexDirection.W, HexDirection.NW
]
	
static var DIRECTION_VECTORS:Array[HexIndex] = [
	HexIndex.from(+1, -1, 0), # NE
	HexIndex.from(+1, 0, -1), # E
	HexIndex.from(0, +1, -1), # SE
	HexIndex.from(-1, +1, 0), # SW
	HexIndex.from(-1, 0, +1), # W
	HexIndex.from(0, -1, +1), # NW
]

static func rotate_direction_right(direction:HexDirection, steps:int = 1) -> HexDirection:
	return ((direction + steps) % 6) as HexDirection

static func rotate_direction_left(direction:HexDirection, steps:int = 1) -> HexDirection:
	return ((direction - steps) % 6) as HexDirection
	
static func rotate_directions_right(directions:Array[HexDirection], steps:int = 1) -> Array[HexDirection]:
	var result:Array[HexDirection] = directions.duplicate()
	for i in range(result.size()):
		result[i] = rotate_direction_right(result[i], steps)
	return result

static func rotate_directions_left(directions:Array[HexDirection], steps:int = 1) -> Array[HexDirection]:
	var result:Array[HexDirection] = directions.duplicate()
	for i in range(result.size()):
		result[i] = rotate_direction_left(result[i], steps)
	return result
		
static func orient_direction(orientation:HexDirection, direction:HexDirection) -> HexDirection:
	return ((orientation + direction) % 6) as HexDirection

static func orient_directions(orientation:HexDirection, directions:Array[HexDirection]) -> Array[HexDirection]:
	var result:Array[HexDirection] = directions.duplicate()
	for i in range(result.size()):
		result[i] = orient_direction(orientation, result[i])
	return result

#endregion

#region Diagonal

enum HexDiagonal { N = 0, NE = 1, SE = 2, S = 3, SW = 4, NW = 5 }

static var ALL_DIAGONALS:Array[HexDiagonal] = [
	HexDiagonal.N, HexDiagonal.NE, HexDiagonal.SE,
	HexDiagonal.S, HexDiagonal.SW, HexDiagonal.NW
]

static var DIAGONAL_VECTORS:Array[HexIndex] = [
	HexIndex.from(+1, -2, +1), # N
	HexIndex.from(+2, -1, -1), # NE
	HexIndex.from(+1, +1, -2), # SE
	HexIndex.from(-1, +2, -1), # S
	HexIndex.from(-2, +1, +1), # SW
	HexIndex.from(-1, -1, +2), # NW
]

static func rotate_diagnonal_right(diagnonal:HexDiagonal, steps:int = 1) -> HexDiagonal:
	return ((diagnonal + steps) % 6) as HexDiagonal

static func rotate_diagnonal_left(diagnonal:HexDiagonal, steps:int = 1) -> HexDiagonal:
	return ((diagnonal - steps) % 6) as HexDiagonal
	
static func rotate_diagnonals_right(diagnonals:Array[HexDiagonal], steps:int = 1) -> Array[HexDiagonal]:
	var result:Array[HexDiagonal] = diagnonals.duplicate()
	for i in range(result.size()):
		result[i] = rotate_diagnonal_right(result[i], steps)
	return result

static func rotate_diagnonals_left(diagnonals:Array[HexDiagonal], steps:int = 1) -> Array[HexDiagonal]:
	var result:Array[HexDiagonal] = diagnonals.duplicate()
	for i in range(result.size()):
		result[i] = rotate_diagnonal_left(result[i], steps)
	return result

static func orient_diagonal(orientation:HexDirection, diagonal:HexDiagonal) -> HexDiagonal:
	return ((orientation + diagonal) % 6) as HexDiagonal

static func orient_diagonals(orientation:HexDirection, diagnonals:Array[HexDiagonal]) -> Array[HexDiagonal]:
	var result:Array[HexDiagonal] = diagnonals.duplicate()
	for i in range(result.size()):
		result[i] = orient_diagonal(orientation, result[i])
	return result
		
#endregion

## Number of hexes in a specified number of rings around a center hex, plus the center hex.
##       1 ->     7
##       2 ->    19
##       5 ->    91
##      10 ->   331
##      17 ->   919
##      20 ->  1261
##      57 ->  9919
##     100 -> 30301 
static func hex_count(rings:int) -> int:
	return 1 + 3 * rings * (rings+1)

static func from(q_:int, r_:int, s_:int = -q_ - r_) -> HexIndex:
	var key:Vector3i = Vector3i(q_, r_, s_)
	return _from_key(key)
	
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
		return HexIndex.from(q_round + roundi(q_ + 0.5*r_), r_round)
	else:
		return HexIndex.from(q_round, r_round + roundi(r_ + 0.5*q_))

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

	return HexIndex.from(q_round, r_round, s_round)

static var _instances:Dictionary[Vector3i, HexIndex] = {}
static func _from_key(key_:Vector3i) -> HexIndex:
	var index:HexIndex = _instances.get(key_)
	if index == null:
		index = HexIndex.new(key_)
		_instances.set(key_, index)
	return index
	
var _key:Vector3i
var _neighbors:Dictionary[HexDirection, HexIndex] = {}

var q:int:
	get(): return _key.x

var r:int:
	get(): return _key.y

var s:int:
	get(): return _key.z

func _init(key_:Vector3i):
	_key = key_
	
func add(index:HexIndex) -> HexIndex:
	return HexIndex.from(q + index.q, r + index.r, s + index.s)

func subtract(index:HexIndex) -> HexIndex:
	return HexIndex.from(q - index.q, r - index.r, s - index.s)
	
func scale(factor:int) -> HexIndex:
	return HexIndex.from(q * factor, r * factor, s * factor)
	
func neighbor(direction:HexDirection) -> HexIndex:
	var neighbor_index:HexIndex = _neighbors.get(direction)
	if neighbor_index == null:
		neighbor_index = add(DIRECTION_VECTORS[direction])
		_neighbors.set(direction, neighbor_index)
	return neighbor_index
	
func diagonal_neighbor(diagonal:HexDiagonal) -> HexIndex:
	return add(DIAGONAL_VECTORS[diagonal])
	
func distance_to(index:HexIndex) -> int:
	var difference:HexIndex = subtract(index)
	return (abs(difference.q) + abs(difference.r) + abs(difference.s)) / 2

func distance_to_center() -> int:
	return (abs(q) + abs(r) + abs(s)) / 2
	
func ring(radius:int) -> Array[HexIndex]:
	var results:Array[HexIndex] = []
	var index = add(DIRECTION_VECTORS[4].scale(radius))
	for direction in HexDirection.values():
		for hex in range(0, radius):
			results.append(index)
			index = index.neighbor(direction)
	return results	

func spiral(radius:int, include_center:bool = true) -> Array[HexIndex]:
	var results:Array[HexIndex] = []
	if include_center:
		results.append(self)
	for k in range(radius):
		results.append_array(ring(k+1))
	return results
	
func to_axial() -> Vector2i:
	return Vector2i(q, r)	
	
func center_point(hex_outer_radius:float) -> Vector2:
	# pointy_hex_to_pixel https://www.redblobgames.com/grids/hexagons/#hex-to-pixel-axial
	var x:float = hex_outer_radius * (sqrt(3.0) * q  +  sqrt(3.0)/2.0 * r)
	var y:float = hex_outer_radius * ((3.0/2.0) * r)
	return Vector2(x, y)

func equals(other:HexIndex) -> bool:
	if not other: return false
	return _key == other._key

func _to_string() -> String:
	return "{q: %d, r: %d, s: %d}" % [q, r, s]

func serialize() -> Variant:
	return [q, r, s]
	
static func deserialize(data:Variant) -> HexIndex:
	return HexIndex.from(data[0], data[1], data[2])
