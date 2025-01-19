class_name RepairDamageDetailUI extends GeneDetailUI

@onready var energy_cost: Label = %EnergyCost
@onready var life_gained: Label = %LifeGained

func show_gene_state(cell_state:CellState) -> void:
	var state:RepairDamageGene.State = cell_state.get_substate(RepairDamageGene.State)
	energy_cost.text = "-%d" % [state.added_life] if state else "0"
	life_gained.text = "+%d" % [state.added_life] if state else "0"
	
