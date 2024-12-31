class_name World extends RefCounted

static var empty_cell:Cell # = EnvionmentGenome.empty_cell
static var bounds_cell:Cell # = EnvionmentGenome.bounds_cell

var _cells:HexStore
var _step_count:int
var _max_hex_distance:int

var step_count:int:
	get: return _step_count
	
var max_hex_distance:int:
	get: return _max_hex_distance
	
func _init(initial_state:HexStore, max_hex_distance:int) -> void:
	_max_hex_distance = max_hex_distance
	_cells = initial_state.duplicate()
	_step_count = 0
	if initial_state.find_max_distance() > _max_hex_distance:
		push_error("World initial_state max distance greater than specified max distance.")
		_max_hex_distance = initial_state.find_max_distance()
	debug("_init : initial_state: %s : max_hex_distance: %d : _max_hex_distance: %d", 
		[initial_state, max_hex_distance, _max_hex_distance])
	
func debug(msg:String, args:Array) -> void:
	if true: prints("World", msg % args)

func step() -> void:
	_step_count += 1
	debug("step : _step_count: %d", [_step_count])
	_cells.visit_all(_cell_use_energy)
	_cells.visit_all(_cell_aquire_energy)

func _cell_use_energy(index:HexIndex, cell:Cell):
	debug("_cell_use_energy : index: %s : cell: %s", [index, cell])
	cell.use_energy(index, self)
	
func _cell_aquire_energy(index:HexIndex, cell:Cell):
	debug("_cell_aquire_energy : index: %s : cell: %s", [index, cell])
	cell.aquire_energy(index, self)
	if cell.energy <= 0.0:
		_cells.set_value(index, null)

func visit_ring(center:HexIndex, radius:int, callable:Callable) -> void:
	for index in center.ring(radius):
		var cell = get_cell(index)
		callable.call(index, cell)
	
func get_cell(index:HexIndex) -> Cell:
	var cell:Cell = _cells.get_value(index)
	if cell == null:
		if index.distance_to_center() > _max_hex_distance:
			cell = bounds_cell
		else:
			cell = empty_cell
	return cell
	
func create_cell(index:HexIndex, cell:Cell) -> void:
	
	if index.distance_to_center() > _max_hex_distance:
		push_error("Battle created cell %s distance at %s greater than allowed max distance." % [cell, index])
		return

	var existing = _cells.get_value(index)
	if existing:
		var resolved = existing.resolve_conflicting_create(cell)
		_cells.set_value(index, resolved)

func serialize() -> Variant:
	var genome_map:Dictionary[Genome, Variant] = {}
	var genomes:Array[Genome]
	for cell in _cells.get_all_values():
		if not genome_map.has(cell.genome):
			genome_map.set(cell.genome, genomes.size())
			genomes.append(cell.genome)
	return {
		genomes = genomes.map(func (genome:Genome): return genome.serialize()),
		cells = _cells.serialize(func (cell:Cell): return cell.serialize(genome_map)),
		max_hex_distance = _max_hex_distance,
		step_count = _step_count
	}
	
static func deserialize(data:Variant) -> World:
	var genomes:Array[Genome] = data['genomes'].map(
		func (entry): return Genome.deserialize(entry))
	var genome_map:Dictionary[Variant, Genome] = {}
	for index:int in range(genomes.size()):
		genome_map.set(index, genomes[index])
	var cells = HexStore.deserialize(data['cells'], 
		func (value): return Cell.deserialize(value, genome_map))
	var max_hex_distance:int = data['max_hex_distance']
	var world:World = World.new(cells, max_hex_distance)
	world._step_count = data['step_count']
	return world
	
func is_empty_cell(cell:Cell) -> bool:
	return cell == empty_cell
	
func is_bounds_cell(cell:Cell) -> bool:
	return cell == bounds_cell
