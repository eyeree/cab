class_name AbsorbNutrientsDetailUI extends GeneDetailUI

@onready var energy_produced: Label = %EnergyProduced

func show_gene_state(cell_state:CellState) -> void:
	var state:AbsorbNutrientsGene.State = cell_state.get_substate(AbsorbNutrientsGene.State)
	energy_produced.text = str(state.energy_produced if state else 0)
	
