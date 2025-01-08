class_name Cell extends RefCounted

enum DamageType {
	Universal,
	Physical,
	Chemical
}

var genome:Genome
var cell_type:CellType
var cell_appearance:CellAppearance

var cell_number:int

var energy:int = 0
var new_energy:int = 0
var energy_wanted:int = 0
var life:int = 0
var new_life:int = 0

var genes:Array[Gene] = []
var immortal:bool = false

var history:Array[Dictionary] = []
var history_index:int = 0 # reverse index

func update_history(new_props:Dictionary) -> void:
	if history.is_empty():
		history.append({})
	history[history.size()-1].merge(new_props)

var last_history:Dictionary:
	get:
		if history.size() > 0:
			return history[history.size()-1]
		else:
			return {}

var max_life:int:
	get: return cell_type.energy_cost

var life_percent:float:
	get: return float(life) / max_life
	
var is_alive:bool:
	get: return life > 0

var is_dead:bool:
	get: return life <= 0

func _init(progenitor:Cell, cell_type_:CellType) -> void:
	cell_type = cell_type_
	genome = cell_type.genome
	life = cell_type.energy_cost
	
	genes.assign(
		cell_type.gene_configs.map(
			func (gene_config:GeneConfig): 
				return gene_config.create_gene(progenitor)))
					
	immortal = has_gene(ImmortalityGene)
	
	cell_appearance = cell_type.cell_appearance.instantiate()
	cell_appearance.attach(self)

func perform_actions(index:HexIndex, world:World) -> void:
	history.append({
		energy = energy,
		life = life,
		energy_wanted = energy_wanted,
	})
	for gene in genes:
		gene.perform_actions(index, world, self)
	
func update_state(index:HexIndex, world:World) -> void:

	update_history({
		new_energy = new_energy,
		new_life = new_life
	})
	
	energy += new_energy
	new_energy = 0
	
	life = min(life + new_life, max_life)
	new_life = 0
	
	if not immortal:
		life -= 1
	
	energy_wanted = 0
	for gene in genes:
		gene.update_state(index, world, self)
		energy_wanted += gene.energy_wanted

	state_changed.emit(index, self)		

signal state_changed(index:HexIndex, cell:Cell)

func take_damage(damage_amount:int, damage_type:DamageType):
	for gene in genes:
		damage_amount -= gene.apply_damage_resistance(damage_amount, damage_type)
		if damage_amount <= 0: return
	life -= damage_amount
	
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
	
func previous_state() -> Cell:
	history_index -= 1
	var history_state = history[history.size() + history_index]
	if history_state.has('previous_cell'):
		return history_state['previous_cell']
	energy = history_state['energy']
	life = history_state['life']
	energy_wanted = history_state['energy_wanted']
	return null
	
func next_state() -> void:
	history_index += 1
	
func _to_string() -> String:
	return "Cell:%s:%s:%d{ energy: %0.0f, new_energy: %0.0f, life: %0.0f, new_life: %0.0f }" \
		% [genome.name, cell_type.name, cell_number, energy, new_energy, life, new_life]
