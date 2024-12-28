class_name Battle extends RefCounted

var _new_state:HexStore
var _old_state:HexStore

var _step_count:int = 0

var step_count:int:
	get: return _step_count
	
func reset(initial_state:HexStore) -> void:
	_new_state = initial_state
	_old_state = null
	_step_count = 0
	
func step() -> void:
	_old_state = _new_state
	_new_state = HexStore.new()
	_old_state.visit_all(_step_cell)
	_step_count += 1

func _step_cell(index:HexIndex, cell:Cell):
	var alive:bool = cell.step(index, self)
	if alive:
		_new_state.set_value(index, cell)

func visit_ring(center:HexIndex, radius:int, callback:Callable) -> void:
	_old_state.visit_ring(center, radius, callback)
	
func create_cell(index:HexIndex, cell:Cell) -> void:
	if _old_state.has_index(index):
		push_error("%s created %s at %s but it already contained %s" % [cell.creator, cell, index, _old_state.get_value(index)])
	else:
		var existing = _new_state.get_value(index)
		if existing:
			var resolved = existing.resolve_conflicting_create(cell)
			push_warning("%s created at %s with conflicting %s resolved as %s" % [cell.creator, cell, index, existing, resolved])
			_new_state.set_value(index, resolved)
