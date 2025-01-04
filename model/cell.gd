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

var energy:float = 0.0
var damage:float = 0.0
var new_energy:float = 0.0
var genes:Array[Gene] = []

var damage_percent:float:
	get: return damage / cell_type.energy_cost
	
var is_dead:bool:
	get: return damage >= cell_type.energy_cost

var is_alive:bool:
	get: return not is_dead

func _init(cell_type_:CellType) -> void:
	cell_type = cell_type_
	genome = cell_type.genome
	cell_appearance = cell_type.cell_appearance.instantiate()

func perform_actions(index:HexIndex, world:World) -> void:
	for gene_state in genes:
		gene_state.perform_actions(index, world, self)
	
func update_state(index:HexIndex, world:World) -> void:
	for gene_state in genes:
		gene_state.update_state(index, world, self)
		
func take_damage(damage_amount:float, damage_type:DamageType):
	for gene_state in genes:
		damage_amount -= gene_state.damage_resistance(damage_amount, damage_type)
		if damage_amount <= 0: return
	damage += damage_amount
	
func get_gene(type:Script) -> Gene:
	for gene in genes:
		if is_instance_of(gene, type): 
			return gene
	return null

func _to_string() -> String:
	return "Cell:%s:%s:%d:%0.0f:%0.2f" % [genome.name, cell_type.name, cell_number, energy, damage_percent]
