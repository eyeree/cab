class_name RepairDamageGeneStatePanel extends GeneStatePanel

@onready var energy_cost: Label = %EnergyCost
@onready var life_gained: Label = %LifeGained

func show_gene_state(cell_state:CellState) -> void:
	var state:RepairDamageGene.State = cell_state.get_substate(RepairDamageGene.State)
	energy_cost.text = "-%d" % [state.added_life] if state and state.added_life != 0 else "0"
	life_gained.text = "+%d" % [state.added_life] if state and state.added_life != 0 else "0"
	
