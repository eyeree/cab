class_name World extends RefCounted

static func _static_init():
	SerializationUtil.register(World) \
		.ignore_properties(World, ['bounds_cell', 'empty_cell'])

static var _next_cell_number:int = 1
static func get_next_cell_number() -> int:
	var cell_number = _next_cell_number
	_next_cell_number += 1
	return cell_number
	
static func debug(msg:String, args:Array) -> void:
	if true: prints("World", msg % args)

class WorldOptions:
	static var default = WorldOptions.new()
	var max_hex_distance:int = 10
	var empty_cell_type:CellType = EnvionmentGenome.empty_cell_type
		
static func create(options:WorldOptions = WorldOptions.default) -> World:	
	var result:World = World.new()
	result.max_hex_distance = options.max_hex_distance
	result.cells = HexStore.new()
	result.empty_cell_type = options.empty_cell_type
	result.empty_cell = options.empty_cell_type.create_cell()
	debug("create | options: %s", [options])
	return result

var cells:HexStore
var step_count:int
var max_hex_distance:int

var empty_cell_type:CellType
var empty_cell:Cell

var bounds_cell:Cell = EnvionmentGenome.bounds_cell_type.create_cell()

func _on_deserialized() -> void:
	empty_cell = empty_cell_type.create_cell()
		
func step() -> void:
	step_count += 1
	debug("step : step_count: %d", [step_count])
	cells.visit_all(_cell_use_energy)
	cells.visit_all(_cell_aquire_energy)

func _cell_use_energy(index:HexIndex, cell:Cell):
	debug("_cell_use_energy : index: %s : cell: %s", [index, cell])
	cell.use_energy(index, self)
	
func _cell_aquire_energy(index:HexIndex, cell:Cell):
	debug("_cell_aquire_energy : index: %s : cell: %s", [index, cell])
	cell.aquire_energy(index, self)
	if cell.energy <= 0.0:
		cells.set_value(index, null)

func visit_ring(center:HexIndex, radius:int, callable:Callable) -> void:
	for index in center.ring(radius):
		var cell = get_cell(index)
		callable.call(index, cell)
	
func get_cell(index:HexIndex) -> Cell:
	if index.distance_to_center() > max_hex_distance:
		return bounds_cell
	else:
		return cells.get_value(index, empty_cell)
	
func set_cell(index:HexIndex, cell:Cell) -> void:
	
	if index.distance_to_center() > max_hex_distance:
		push_error("Battle created cell %s distance at %s greater than allowed max distance." % [cell, index])
		return

	var existing = cells.get_value(index)
	if existing:
		var resolved = existing.resolve_conflicting_create(cell)
		cells.set_value(index, resolved)
	
func is_empty_cell(cell:Cell) -> bool:
	return cell == empty_cell
	
func is_bounds_cell(cell:Cell) -> bool:
	return cell == bounds_cell
