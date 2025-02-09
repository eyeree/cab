class_name World extends RefCounted

static var empty_args:Array = []

static func debug(msg:String, args:Array = empty_args) -> void:
	if false: prints("World", msg % args)

static var debug_cell_numbers:Array[int] = []
static func debug_cell(cell:Cell, msg:String, args:Array = empty_args) -> void:
	if debug_cell_numbers.has(cell.cell_number): 
		prints("Cell %s" % cell, msg % args)

var _rings:int
var _cells:HexStore
var _world_state:WorldState

var current_step:int = -1

var _cell_number:int = 0
func allocate_cell_number() -> int:
	_cell_number += 1
	return _cell_number
	
var _genomes:Array[Genome] = []
var _genome_rank_index:int = 0
	
var environment_genome := EnvironmentGenome.new()
var bounds_cell:Cell

signal cell_changed(index:HexIndex, new_cell:Cell)

class WorldOptions:
	var rings:int = 10
	var initial_content:HexStore
	var world_state:WorldState
		
func _init(options:WorldOptions):	
	
	_rings = options.rings
	_world_state = options.world_state
	
	_cell_number = 0
	
	bounds_cell = Cell.new(self, HexIndex.INVALID, environment_genome.bounds_cell_type)
	
	_cells = HexStore.new()
	for index:HexIndex in HexIndex.CENTER.spiral(_rings, true):
		var cell_type:CellType = options.initial_content.get_content(index)
		if cell_type == null:
			cell_type = environment_genome.empty_cell_type
		if not _genomes.has(cell_type.genome):
			_genomes.append(cell_type.genome)
		set_cell(index, cell_type)
		
	#prints("----- STEP %d -----" % 0)
	
	for index:HexIndex in HexIndex.CENTER.spiral(_rings, true):
		var cell:Cell = get_cell(index)
		var cell_state:CellState = _world_state.get_history_entry(index, 0)
		cell.update_state(cell_state)	
			
func step(step_number:int) -> void:
	#prints("----- STEP %d -----" % step_number)
	current_step = step_number
	_cells.visit_all(_cell_perform_actions)
	_cells.visit_all(_cell_update_state)
	_genome_rank_index = min(_genome_rank_index + 1, _genomes.size())

func _cell_perform_actions(index:HexIndex, cell:Cell):
	var cell_state:CellState = _world_state.get_history_entry(index, current_step)
	cell.perform_actions(cell_state)
	
func _cell_update_state(index:HexIndex, cell:Cell):
	var cell_state:CellState = _world_state.get_history_entry(index, current_step)
	cell.update_state(cell_state)
	if cell.is_dead:
		set_cell(index, environment_genome.empty_cell_type)

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
	
	var cell_state:CellState = _world_state.get_history_entry(index, current_step)
	cell_state.start_energy = cell.energy
	cell_state.start_life = cell.life
				
	_cells.set_content(index, cell)
	cell_changed.emit(index, cell)
	
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
