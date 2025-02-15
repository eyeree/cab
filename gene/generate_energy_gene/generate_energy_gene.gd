class_name GenerateEnergyGene extends Gene
	
var _energy_per_step:int = 0

func _init(cell_:Cell, config:Config) -> void:
	super._init(cell_)
	_energy_per_step = config.energy_per_step

func perform_actions() -> void:
	cell.new_energy += _energy_per_step
	add_state(State.new(_energy_per_step))
				
class State extends GeneState:
	var energy_produced:int
	func _init(energy_produced_:int):
		energy_produced = energy_produced_
		
class Config extends GeneConfig:
	@export var energy_per_step:int = 1
	
	func create_gene(cell:Cell, _progenitor:Cell) -> GenerateEnergyGene:
		return GenerateEnergyGene.new(cell, self)

	func get_energy_cost() -> int:
		return gene_type.energy_cost * energy_per_step
		
class Type extends GeneType:
	
	func _init() -> void:
		name = 'GenerateEnergy'
		energy_cost = 1

	func create_config() -> Config:
		return Config.new(self)

static var gene_type_ = Type.new()
