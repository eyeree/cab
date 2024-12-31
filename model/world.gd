class_name World extends RefCounted

static var _serialization = SerializationUtil.register(World)

static var empty_cell:Cell # = EnvionmentGenome.empty_cell
static var bounds_cell:Cell # = EnvionmentGenome.bounds_cell

var cells:HexStore
var step_count:int
var max_hex_distance:int

static func debug(msg:String, args:Array) -> void:
	if true: prints("World", msg % args)

static func create(initial_state:HexStore, max_hex_distance:int) -> void:
	
	if initial_state.find_max_distance() > max_hex_distance:
		push_error("World initial_state max distance greater than specified max distance.")
		max_hex_distance = initial_state.find_max_distance()
		
	var result:World = World.new()
	result.max_hex_distance = max_hex_distance
	result.cells = initial_state.duplicate()
	
	debug("create : initial_state: %s : max_hex_distance: %d", [initial_state, max_hex_distance])
	
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

func _on_serialize(data:Dictionary):
	var genome_map:Dictionary[Genome, Variant] = {}
	for cell in cells.get_all_values():
		if not genome_map.has(cell.genome):
			genome_map.set(cell.genome, genome_map.size())
	
	#return {
		#genomes = genomes.map(func (genome:Genome): return genome.serialize()),
		#cells = _cells.serialize(func (cell:Cell): return cell.serialize(genome_map)),
		#max_hex_distance = _max_hex_distance,
		#step_count = _step_count
	#}
	
#static func deserialize(data:Variant) -> World:
	#var genomes:Array[Genome] = data['genomes'].map(
		#func (entry): return Genome.deserialize(entry))
	#var genome_map:Dictionary[Variant, Genome] = {}
	#for index:int in range(genomes.size()):
		#genome_map.set(index, genomes[index])
	#var cells = HexStore.deserialize(data['cells'], 
		#func (value): return Cell.deserialize(value, genome_map))
	#var max_hex_distance:int = data['max_hex_distance']
	#var world:World = World.new(cells, max_hex_distance)
	#world._step_count = data['step_count']
	#return world
	
func is_empty_cell(cell:Cell) -> bool:
	return cell == empty_cell
	
func is_bounds_cell(cell:Cell) -> bool:
	return cell == bounds_cell
