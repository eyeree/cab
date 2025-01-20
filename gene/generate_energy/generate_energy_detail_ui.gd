class_name AbsorbNutrientsDetailUI extends GeneDetailUI

@onready var energy_gained: Label = %EnergyGained

func show_gene_state(cell_state:CellState) -> void:
	var state:GenerateEnergyGene.State = cell_state.get_substate(GenerateEnergyGene.State)
	energy_gained.text = "+%d" % [state.energy_produced] if state else "0"
	
