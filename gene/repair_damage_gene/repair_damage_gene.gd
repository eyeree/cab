class_name RepairDamageGene extends Gene

var max_repaired_amount:int
var life_needed:int

func _init(cell_:Cell, config:RepairDamageGeneConfig) -> void:
	super._init(cell_)
	max_repaired_amount = config.max_repaired_amount
	
func perform_actions() -> void:
	if life_needed == 0: return
	var added_life = min(life_needed, cell.energy)
	cell.new_life += added_life
	cell.energy -= added_life
	add_state(State.new(added_life))

func update_state() -> void:
	life_needed = cell.max_life - cell.life
	energy_wanted = min(max_repaired_amount, life_needed)
	
class State extends GeneState:
	var added_life:int
	func _init(added_life_:int) -> void:
		added_life = added_life_
