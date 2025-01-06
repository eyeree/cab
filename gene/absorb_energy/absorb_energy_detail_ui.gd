extends PanelContainer

@onready var energy_per_step_edit: LineEdit = %EnergyPerStepEdit

func show_gene(gene:AbsorbEnergyGene) -> void:
	energy_per_step_edit.text = str(gene._energy_per_step)
