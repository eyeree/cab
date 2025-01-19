class_name Cell extends RefCounted

enum DamageType {
	Universal,
	Physical,
	Chemical
}

var genome:Genome
var cell_type:CellType

var cell_number:int
var title:String

var energy:int = 0
var new_energy:int = 0
var energy_wanted:int = 0
var max_energy:int = 0
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

func _init(progenitor:Cell, cell_type_:CellType) -> void:
	
	cell_type = cell_type_
	genome = cell_type.genome
	
	max_energy = cell_type.energy_cost * 2
	new_energy = 1
	energy = 0
	
	max_life = cell_type.energy_cost
	new_life = max_life
	life = 0
	
	genes.assign(
		cell_type.gene_configs.map(
			func (gene_config:GeneConfig): 
				return gene_config.create_gene(self, progenitor)))
					
	immortal = has_gene(ImmortalityGene)
	
	for gene:Gene in genes:
		gene.init_cell(self)

func perform_actions(state_:CellState) -> void:
	
	state = state_
	
	state.start_energy = energy
	state.start_life = life
	#prints('cell %s - perform_actions - life: %d - new_life: %d' % [self, life, new_life])
	
	if not immortal:
		life -= 1
		#prints('  life -= 1: %d' % [life])

	for gene in genes:
		gene.perform_actions()

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
	for gene in genes:
		damage_amount -= gene.apply_damage_resistance(source_index, damage_amount, damage_type)
		if damage_amount <= 0: return 0
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

func _to_string() -> String:
	return "Cell:%s:%s:%d{ energy: %0.0f, new_energy: %0.0f, life: %0.0f, new_life: %0.0f }" \
		% [genome.name, cell_type.name, cell_number, energy, new_energy, life, new_life]

class DamageTakenGeneState extends GeneState:
	var source_index:HexIndex
	var damage_amount:int
	var damage_type:DamageType
	func _init(source_index_:HexIndex, damage_amount_:int, damage_type_:DamageType) -> void:
		source_index = source_index_
		damage_amount = damage_amount_
		damage_type = damage_type_
