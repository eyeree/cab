class_name World extends RefCounted

static var empty_args:Array = []
static func debug(msg:String, args:Array = empty_args) -> void:
	if false: prints("World", msg % args)

var _rings:int
var _cells:HexStore
var _world_history:WorldHistory

var _cell_number:int = 0
func allocate_cell_number() -> int:
	_cell_number += 1
	return _cell_number
	
static var bounds_cell:Cell = EnvironmentGenome.bounds_cell_type.create_cell()

signal cell_changed(index:HexIndex, new_cell:Cell)

class WorldOptions:
	var rings:int = 10
	var initial_content:HexStore
	var world_history:WorldHistory
		
func _init(options:WorldOptions):	
	
	_rings = options.rings
	_world_history = options.world_history
	
	_cell_number = 0
	
	_cells = HexStore.new()
	for index:HexIndex in HexIndex.CENTER.spiral(_rings, true):
		var content:Cell = options.initial_content.get_content(index)
		if content != null:
			set_cell(index, content)
		
	for index:HexIndex in HexIndex.CENTER.spiral(_rings, true):
		var cell:Cell = get_cell(index)
		if cell:
			var cell_history:Dictionary = _world_history.get_history_entry(index, 0)
			cell.update_state(index, self, cell_history)	
		
func run(steps:int, on_progress:Callable) -> void:
	for step_number in range(1, steps + 1):
		var start_ms:int = Time.get_ticks_msec()
		_step(step_number)
		var end_ms:int = Time.get_ticks_msec()
		var stop = on_progress.call(step_number, end_ms - start_ms)
		if stop: return
			
func _step(step_number:int) -> void:
	_cells.visit_all(_cell_perform_actions.bind(step_number))
	_cells.visit_all(_cell_update_state.bind(step_number))

func _cell_perform_actions(index:HexIndex, cell:Cell, step_number:int):
	var cell_history:Dictionary = _world_history.get_history_entry(index, step_number)
	if cell:
		cell.perform_actions(index, self, cell_history)
		if cell.is_dead:
			cell_history['died'] = true
			set_cell(index, null)
	
func _cell_update_state(index:HexIndex, cell:Cell, step_number:int):
	var cell_history:Dictionary = _world_history.get_history_entry(index, step_number)
	if cell:
		cell.update_state(index, self, cell_history)

func visit_ring(center:HexIndex, radius:int, callable:Callable) -> void:
	for index in center.ring(radius):
		var cell = get_cell(index)
		callable.call(index, cell)
	
func get_cell(index:HexIndex) -> Cell:
	if index.distance_to_center() > _rings:
		return bounds_cell
	else:
		var result = _cells.get_content(index)
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
