class_name World extends Node

static var empty_args:Array = []

static func debug(msg:String, args:Array = empty_args) -> void:
	if false: prints("World", msg % args)

static var debug_cell_numbers:Array[int] = []
static func debug_cell(cell:Cell, msg:String, args:Array = empty_args) -> void:
	if debug_cell_numbers.has(cell.cell_number): 
		prints("Cell %s" % cell, msg % args)

var _rings:int
var _steps:int
var _initial_content:HexStore

var _cells:HexStore

var state:WorldState

var current_step := 0

var _cell_number := 0
func allocate_cell_number() -> int:
	_cell_number += 1
	return _cell_number
	
var _genomes:Array[Genome] = []
var _genome_rank_index := 0
	
var environment_genome := EnvironmentGenome.new()
var bounds_cell := Cell.new(self, HexIndex.INVALID, environment_genome.bounds_cell_type)

signal load_started()
signal load_progress(steps_loaded:int)
signal load_finished()

var _is_process_loading := false

var _load_thread:Thread = null
var _stop_loading := false

#signal cell_changed(index:HexIndex, new_cell:Cell)

class WorldOptions:
	var rings:int
	var steps:int
	var initial_content:HexStore

#var _dispatch_qeueue:DispatchQueue

func load(options:WorldOptions):	
	
	_rings = options.rings
	_steps = options.steps
	_initial_content = options.initial_content
	
	current_step = 0
	
	#_dispatch_qeueue = DispatchQueue.new()
	#_dispatch_qeueue.create_concurrent(max(1, OS.get_processor_count() - 2))
	#prints('_dispatch_queue - threaded:', _dispatch_qeueue.is_threaded(), 'treads:', _dispatch_qeueue.get_thread_count())
	
	if OS.has_feature('nothreads'):		
		_is_process_loading = true
	else:
		_background_load()		
	
func _init_state():
	state = WorldState.new(_rings, _steps)
	
func _init_cells():
	_cells = HexStore.new()
	
	for index:HexIndex in HexIndex.CENTER.spiral(_rings, true):
		var cell_type:CellType = _initial_content.get_content(index)
		if cell_type == null:
			cell_type = environment_genome.empty_cell_type
		if not _genomes.has(cell_type.genome):
			_genomes.append(cell_type.genome)
		set_cell(index, cell_type)
		
	for index:HexIndex in HexIndex.CENTER.spiral(_rings, true):
		var cell:Cell = get_cell(index)
		var cell_state:CellState = state.get_history_entry(index, 0)
		cell.update_state(cell_state)	
		
func _process(_delta:float) -> void:
	
	if not _is_process_loading: 
		return
		
	var start_ms:int = Time.get_ticks_msec()
	
	if current_step == 0:
		load_started.emit.call_deferred()
		_init_state()
		_init_cells()
		
	while _step() and not _stop_loading:
		var end_ms:int = Time.get_ticks_msec()
		var elapsed_ms:int = end_ms - start_ms
		if elapsed_ms >= 50: return
		
	_stop_loading = false
	_is_process_loading = false
	load_finished.emit.call_deferred()
			
func _background_load() -> void:
	
	if _load_thread:
		_stop_loading = true
		_load_thread.wait_to_finish()
		_load_thread = null
		_stop_loading = false
		
	_load_thread = Thread.new()
	_load_thread.start(
		func ():
			load_started.emit.call_deferred()
			_init_state()
			_init_cells()
			while _step() and not _stop_loading:
				pass
			_stop_loading = false
			load_finished.emit.call_deferred())
			
func _exit_tree() -> void:
	stop_loading()
				
func stop_loading() -> void:
	if _load_thread and _load_thread.is_alive():
		_stop_loading = true
		_load_thread.wait_to_finish()
	else:
		_is_process_loading = false
		
func _step() -> bool:
	if current_step == _steps:
		return false
	else:
		current_step += 1
		var cells := _cells.get_all_content()
		
		#var cells_per_thread:int = cells.size() / _dispatch_qeueue.get_thread_count()
		#for thread_number in _dispatch_qeueue.get_thread_count():
			#var start_index := thread_number * cells_per_thread
			#var end_index := start_index + cells_per_thread
			#if thread_number == _dispatch_qeueue.get_thread_count() - 1:
				#end_index = cells.size() -1
			#_dispatch_qeueue.dispatch(func ():
				##prints('actions', thread_number, start_index, end_index)
				#for index in range(start_index, end_index):
					#_cell_perform_actions(cells[index]))
		#await _dispatch_qeueue.all_tasks_finished
##
		#for thread_number in _dispatch_qeueue.get_thread_count():
			#var start_index := thread_number * cells_per_thread
			#var end_index := start_index + cells_per_thread
			#if thread_number == _dispatch_qeueue.get_thread_count() - 1:
				#end_index = cells.size() -1
			#_dispatch_qeueue.dispatch(func ():
				##prints('updates', thread_number, start_index, end_index)
				#for index in range(start_index, end_index):
					#_cell_update_state(cells[index]))
		#await _dispatch_qeueue.all_tasks_finished
		
		#for cell in cells:
			#_dispatch_qeueue.dispatch(_cell_perform_actions.bind(cell))	
		#await _dispatch_qeueue.all_tasks_finished
		#
		#for cell in cells:
			#_dispatch_qeueue.dispatch(_cell_update_state.bind(cell))	
		#await _dispatch_qeueue.all_tasks_finished
		
		for cell in cells:
			var cell_state:CellState = state.get_history_entry(cell.index, current_step)
			cell.perform_actions(cell_state)
		for cell in cells:
			var cell_state:CellState = state.get_history_entry(cell.index, current_step)
			cell.update_state(cell_state)
			if cell.is_dead:
				set_cell(cell.index, environment_genome.empty_cell_type)
				
		_genome_rank_index = min(_genome_rank_index + 1, _genomes.size())
		load_progress.emit.call_deferred(current_step)
		return true

func _cell_perform_actions(cell:Cell):
	var cell_state:CellState = state.get_history_entry(cell.index, current_step)
	cell.perform_actions(cell_state)
	
func _cell_update_state(cell:Cell):
	var cell_state:CellState = state.get_history_entry(cell.index, current_step)
	cell.update_state(cell_state)
	if cell.is_dead:
		set_cell(cell.index, environment_genome.empty_cell_type)
	
func visit_ring(center:HexIndex, radius:int, callable:Callable) -> void:
	for index in center.ring(radius):
		var cell = get_cell(index)
		callable.call(index, cell)
	
func get_cell(index:HexIndex) -> Cell:
	if index.distance_to_center() > _rings:
		return bounds_cell
	else:
		return _cells.get_content(index)
	
func set_cell(index:HexIndex, cell_type:CellType, progenitor:Cell = null) -> Cell:
	
	if index.distance_to_center() > _rings:
		push_error("cell %s distance at %s greater than allowed max distance." % [cell_type, index])
		return
		
	var cell := Cell.new(self, index, cell_type, progenitor)
	
	var cell_state:CellState = state.get_history_entry(index, current_step)
	cell_state.start_energy = cell.energy
	cell_state.start_life = cell.life
				
	_cells.set_content(index, cell)
	
	return cell
	
func is_empty_cell(cell:Cell) -> bool:
	return cell.cell_type == environment_genome.empty_cell_type
	
func is_bounds_cell(cell:Cell) -> bool:
	return cell == bounds_cell

func get_genome_rank(genome:Genome) -> int:
	var index:int = _genomes.find(genome)
	if index == -1:
		push_error("genome %s not found in world %s" % [genome, self])
		return -1
	index -= _genome_rank_index
	if index < 0:
		index = _genomes.size() - index
	return index
