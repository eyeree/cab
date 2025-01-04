class_name World extends RefCounted

static func _static_init():
	SerializationUtil.register(World) \
		.ignore_properties(World, ['bounds_cell', 'empty_cell'])

static var _next_cell_number:int = 1
static func get_next_cell_number() -> int:
	var cell_number = _next_cell_number
	_next_cell_number += 1
	return cell_number
	
static var empty_args:Array = []
static func debug(msg:String, args:Array = empty_args) -> void:
	if true: prints("World", msg % args)

var _rings:int
var rings:int:
	set(value): _on_rings_set(value)
	get: return _rings

var _cells:HexStore = HexStore.new()

var step_count:int = 0

var _empty_cell_type:CellType
var empty_cell_type:CellType:
	set(value): _on_empty_cell_type_set(value)
	get: return _empty_cell_type

static var bounds_cell:Cell = EnvionmentGenome.bounds_cell_type.create_cell()

signal cell_changed(index:HexIndex, new_cell:Cell)
signal size_changed(rings:int)

class WorldOptions:
	var rings:int = 10
	var empty_cell_type:CellType = EnvionmentGenome.empty_cell_type
	var initial_content:HexStore = HexStore.new()
		
func _init(options:WorldOptions = WorldOptions.new()):	
	debug("_init | rings_: %d | empty_cell_type_: %s | initial_content.size(): %d" 
		% [options.rings, options.empty_cell_type, options.initial_content.size()])
	
	_rings = options.rings
	_empty_cell_type = options.empty_cell_type
	
	for index:HexIndex in HexIndex.CENTER.spiral(_rings, true):
		var content:Cell = options.initial_content.get_content(index)
		if content == null:
			content = _empty_cell_type.create_cell()
		_cells.set_content(index, content)
	
func _on_rings_set(new_value:int) -> void:
	var old_value = _rings
	_rings = new_value
	debug("_on_rings_set | old_value: %d | new_value: %d | new_hex_count: %d" % 
		[old_value, new_value, HexIndex.hex_count(new_value)])
	size_changed.emit(new_value)
	if new_value < old_value:
		for radius in range(new_value, old_value):
			for index in HexIndex.CENTER.ring(radius+1):
				_cells.clear_content(index)
	elif new_value > old_value:
		for radius in range(old_value, new_value):
			for index in HexIndex.CENTER.ring(radius+1):
				var cell = empty_cell_type.create_cell()
				set_cell(index, cell)

func _on_empty_cell_type_set(new_empty_cell_type:CellType) -> void:
	var old_empty_cell_type = _empty_cell_type
	_empty_cell_type = new_empty_cell_type
	debug("_on_empty_cell_type_set | old_value: %s | new_value: %s | hex_count: %d" % 
		[old_empty_cell_type, new_empty_cell_type, HexIndex.hex_count(rings)])
	var num_empty_cells:int = 0
	for index in HexIndex.CENTER.spiral(rings, true):
		var existing_cell = _cells.get_content(index)
		if existing_cell == null or existing_cell.cell_type == old_empty_cell_type:
			var new_cell = empty_cell_type.create_cell()
			set_cell(index, new_cell)
			num_empty_cells += 1
	debug("_on_empty_cell_type_set | num_empty_cells: %d" % [num_empty_cells])
			
func step() -> void:
	step_count += 1
	debug("step | step_count: %d", [step_count])
	_cells.visit_all(_cell_perform_actions)
	_cells.visit_all(_cell_update_state)

func update_state() -> void:
	debug("update_state | step_count: %d", [step_count])
	_cells.visit_all(_cell_update_state)
	
func _cell_perform_actions(index:HexIndex, cell:Cell):
	debug("_cell_perform_actions | index: %s | cell: %s", [index, cell])
	cell.perform_actions(index, self)
	
func _cell_update_state(index:HexIndex, cell:Cell):
	debug("_cell_update_state | index: %s | cell: %s", [index, cell])
	cell.update_state(index, self)
	if cell.health <= 0.0:
		_cells.set_content(index, null)

func visit_ring(center:HexIndex, radius:int, callable:Callable) -> void:
	for index in center.ring(radius):
		var cell = get_cell(index)
		callable.call(index, cell)
	
func get_cell(index:HexIndex) -> Cell:
	if index.distance_to_center() > rings:
		return bounds_cell
	else:
		return _cells.get_content(index)
	
func set_cell(index:HexIndex, cell:Cell) -> void:
	
	if index.distance_to_center() > rings:
		push_error("cell %s distance at %s greater than allowed max distance." % [cell, index])
		return
		
	_cells.set_content(index, cell)
	
	cell_changed.emit(index, cell)
	
func is_empty_cell(cell:Cell) -> bool:
	return cell.cell_type == empty_cell_type
	
func is_bounds_cell(cell:Cell) -> bool:
	return cell == bounds_cell
