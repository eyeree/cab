class_name GenerateEnergyGene extends Gene
	
var _energy_per_step:int = 0

func _init(cell_:Cell, config:GenerateEnergyGeneConfig) -> void:
	super._init(cell_)
	_energy_per_step = config.energy_per_step

func perform_actions() -> void:
	cell.new_energy += _energy_per_step
	add_state(State.new(_energy_per_step))
				
class State extends GeneState:
	var energy_produced:int
	func _init(energy_produced_:int):
		energy_produced = energy_produced_
