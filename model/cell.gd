class_name Cell extends RefCounted

enum DamageType {
	Universal,
	Physical,
	Chemical
}

var genome:Genome
var cell_type:CellType
var orientation:HexIndex.HexDirection = HexIndex.HexDirection.E
var progenitor:Cell

var cell_number:int
var title:String

var step_created:int
var age:int:
	get: return world.current_step - step_created
	
var generation:int = 0

var energy:int = 0
var new_energy:int = 0
var energy_wanted:int = 0
var max_energy:int = 0

var energy_percent:float:
	get: return float(energy) / max_energy

var life:int = 0
var new_life:int = 0
var max_life:int = 0

var genes:Array[Gene] = []
var immortal:bool = false

var index:HexIndex = HexIndex.INVALID

var world_ref:WeakRef
var world:World:
	get: return world_ref.get_ref() if world_ref else null
	
var state:CellState

var life_percent:float:
	get: return float(life) / max_life

var is_alive:bool:
	get: return life > 0

var is_dead:bool:
	get: return life <= 0
	
func _init(world_:World, index_:HexIndex, cell_type_:CellType, progenitor_:Cell = null) -> void:
	
	world_ref = weakref(world_)
	index = index_
	cell_type = cell_type_
	progenitor = progenitor_

	genome = cell_type.genome
	cell_number = world.allocate_cell_number()
	step_created = world.current_step
	
	title = "%s:%s:%d" % [genome.name, cell_type.name, cell_number]

	max_energy = cell_type.energy_cost * 2
	new_energy = 0
	energy = 0
	
	max_life = cell_type.energy_cost
	new_life = max_life
	life = 0
	
	genes.assign(
		cell_type.gene_configs.map(
			func (gene_config:GeneConfig): 
				return gene_config.create_gene(self)))
					
	immortal = has_gene(ImmortalityGene)
	
	if progenitor:
		var progenitor_direction := index.neighbor_direction(progenitor.index)
		orientation = HexIndex.opposite_direction(progenitor_direction)
		#prints("cell", self, index, orientation, progenitor, progenitor.index, progenitor.orientation, progenitor_direction)
		if progenitor.cell_type == cell_type:
			generation = progenitor.generation + 1	
	elif genome != world.environment_genome:
		#prints("cell", self, index, orientation)
		pass
			
	for gene:Gene in genes:
		gene.init_cell()

func perform_actions(state_:CellState) -> void:
	
	state = state_
	
	state.start_energy = energy
	state.start_life = life
	#prints('cell %s - perform_actions - life: %d - new_life: %d' % [self, life, new_life])
	
	for gene in genes:
		gene.perform_actions()

	_connected_life = -1
	
	#prints('  life after: %d - new_life: %d' % [life, new_life])
	
func update_state(state_:CellState) -> void:

	state = state_
	
	#prints('cell %s - update_state - life: %d - new_life: %d' % [self, life, new_life])

	state.cell = self

	# energy
		
	state.end_energy = energy
	state.new_energy = new_energy
	state.max_energy = max_energy
	
	energy = min(max_energy, energy + new_energy)
	new_energy = 0

	# life
	
	state.end_life = life
	state.new_life = new_life
	state.max_life = max_life
	
	life = min(life + new_life, max_life)
	new_life = 0
	
	#prints('  updated life: %d - max_life: %d' % [life, max_life])

	energy_wanted = 0
	for gene in genes:
		gene.update_state()
		energy_wanted += gene.energy_wanted
	state.energy_wanted = energy_wanted

func take_damage(source_index:HexIndex, damage_amount:int, damage_type:DamageType) -> int:
	
	if immortal:
		return 0
		
	for gene in genes:
		damage_amount -= gene.apply_damage_resistance(source_index, damage_amount, damage_type)
		if damage_amount <= 0: 
			return 0
			
	life -= damage_amount
	state.gene_states.append(DamageTakenGeneState.new(source_index, damage_amount, damage_type))
	
	return damage_amount
	
func get_gene(type:Script) -> Gene:
	for gene in genes:
		if is_instance_of(gene, type): 
			return gene
	return null

func has_gene(type:Script) -> bool:
	for gene in genes:
		if is_instance_of(gene, type): 
			return true
	return false
	
func get_edge_attribute_value(direction:HexIndex.HexDirection, attribute:StringName) -> float:
	for gene:Gene in genes:
		if gene.provides_edge_attribute(attribute):
			return gene.get_edge_attribute_value(direction, attribute)
	return 0.0

func get_cell_attribute_value(attribute:StringName) -> float:
	
	match attribute:
		"life_percent":
			return life_percent
		"energy_percent":
			return energy_percent
		"age":
			return float(age)
		"generation":
			return float(generation)
			
	for gene:Gene in genes:
		if gene.provides_cell_attribute(attribute):
			return gene.get_cell_attribute_value(attribute)
			
	return 0.0
	
func _to_string() -> String:
	return title

var _connected_life:int = -1
var connected_life:int:
	get():
		if _connected_life == -1:
			ConnectedLifeVisitor.visit(self)
		return _connected_life
		
class ConnectedLifeVisitor extends HexIndex.VisitQueue:
	
	static func visit(cell:Cell):
		ConnectedLifeVisitor.new(cell)
	
	var world:World
	var target_genome:Genome
	var total_life:int = 0
	
	func _init(cell:Cell) -> void:
		world = cell.world
		target_genome = cell.genome
		_do_visiting(cell.index)
		for index:HexIndex in visited:
			var visited_cell:Cell = world.get_cell(index)
			visited_cell._connected_life = total_life
			
	func _visit(index:HexIndex) -> void:
		var cell:Cell = world.get_cell(index)
		total_life += cell.life
		for neighbor_index:HexIndex in index.ring(1):
			var neighbor_cell:Cell = world.get_cell(neighbor_index)
			if neighbor_cell != null && neighbor_cell.genome == target_genome:
				_enqueue(neighbor_index)
		
class DamageTakenGeneState extends GeneState:
	var source_index:HexIndex
	var damage_amount:int
	var damage_type:DamageType
	func _init(source_index_:HexIndex, damage_amount_:int, damage_type_:DamageType) -> void:
		source_index = source_index_
		damage_amount = damage_amount_
		damage_type = damage_type_
