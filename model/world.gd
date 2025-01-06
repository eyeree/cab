class_name World extends RefCounted

static func _static_init():
	SerializationUtil.register(World) \
		.ignore_properties(World, ['bounds_cell', 'empty_cell'])

static var empty_args:Array = []
static func debug(msg:String, args:Array = empty_args) -> void:
	if false: prints("World", msg % args)

var _rings:int = 0
var _cells:HexStore = HexStore.new()
var _step_count:int = 0

var step_count:int:
	get: return _step_count

var _cell_number:int = 0
func allocate_cell_number() -> int:
	_cell_number += 1
	return _cell_number
	
static var bounds_cell:Cell = EnvironmentGenome.bounds_cell_type.create_cell()

signal cell_changed(index:HexIndex, new_cell:Cell)

class WorldOptions:
	var rings:int = 10
	var initial_content:HexStore = HexStore.new()
		
func init(options:WorldOptions = WorldOptions.new()):	
	debug("init | rings_: %d | initial_content.size(): %d | hex_count: %d" 
		% [options.rings, options.initial_content.size(), HexIndex.hex_count(options.rings)])
	
	_rings = options.rings
	_step_count = 0
	_cell_number = 0
	
	_cells = HexStore.new()
	for index:HexIndex in HexIndex.CENTER.spiral(_rings, true):
		var content:Cell = options.initial_content.get_content(index)
		if content == null:
			content = EnvironmentGenome.empty_cell_type.create_cell()
		set_cell(index, content)
	
func step() -> void:
	_step_count += 1
	debug("step | _step_count: %d", [_step_count])
	_cells.visit_all(_cell_perform_actions)
	_cells.visit_all(_cell_update_state)

func update_state() -> void:
	debug("update_state | _step_count: %d", [_step_count])
	_cells.visit_all(_cell_update_state)
	
func _cell_perform_actions(index:HexIndex, cell:Cell):
	cell.perform_actions(index, self)
	if cell.is_dead:
		set_cell(index, EnvironmentGenome.empty_cell_type.create_cell())
	
func _cell_update_state(index:HexIndex, cell:Cell):
	cell.update_state(index, self)

func visit_ring(center:HexIndex, radius:int, callable:Callable) -> void:
	for index in center.ring(radius):
		var cell = get_cell(index)
		callable.call(index, cell)
	
func get_cell(index:HexIndex) -> Cell:
	if index.distance_to_center() > _rings:
		return bounds_cell
	else:
		var result = _cells.get_content(index)
		if result == null:
			push_error('null cell at index', index, HexIndex.CENTER)
		return result
	
func set_cell(index:HexIndex, cell:Cell) -> void:
	
	if index.distance_to_center() > _rings:
		push_error("cell %s distance at %s greater than allowed max distance." % [cell, index])
		return
		
	cell.cell_number = allocate_cell_number()
	_cells.set_content(index, cell)
	
	cell_changed.emit(index, cell)
	
func is_empty_cell(cell:Cell) -> bool:
	return cell.cell_type == EnvironmentGenome.empty_cell_type
	
func is_bounds_cell(cell:Cell) -> bool:
	return cell == bounds_cell
