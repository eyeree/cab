class_name Cell extends RefCounted

enum DamageType {
	Universal,
	Physical,
	Chemical
}

var genome:Genome
var cell_type:CellType

var cell_number:int

var energy:int = 0
var new_energy:int = 0
var energy_wanted:int = 0
var life:int = 0
var new_life:int = 0

var genes:Array[Gene] = []
var immortal:bool = false

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

func perform_actions(index:HexIndex, world:World, cell_history:Dictionary) -> void:
	for gene in genes:
		gene.perform_actions(index, world, self, cell_history)
	
func update_state(index:HexIndex, world:World, cell_history:Dictionary) -> void:

	energy += new_energy
	
	life = min(life + new_life, max_life)
	
	energy_wanted = 0
	for gene in genes:
		gene.update_state(index, world, self, cell_history)
		energy_wanted += gene.energy_wanted

	cell_history['cell_type'] = cell_type
	cell_history['energy'] = energy
	cell_history['life'] = life
	cell_history['energy_wanted'] = energy_wanted
	cell_history['new_energy'] = new_energy
	cell_history['new_life'] = new_life
	
	new_energy = 0
	new_life = 0

	if not immortal:
		life -= 1

func take_damage(damage_amount:int, damage_type:DamageType) -> int:
	for gene in genes:
		damage_amount -= gene.apply_damage_resistance(damage_amount, damage_type)
		if damage_amount <= 0: return 0
	life -= damage_amount
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
