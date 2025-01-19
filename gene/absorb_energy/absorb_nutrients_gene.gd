class_name AbsorbNutrientsGene extends Gene
	
var _energy_per_step:int = 0

func _init(cell_:Cell, config:AbsorbNutrientsGeneConfig) -> void:
	super._init(cell_)
	_energy_per_step = config.energy_per_step

func perform_actions() -> void:
	cell.new_energy += _energy_per_step
	add_state(AbsorbEnergyGeneState.new(_energy_per_step))
				
class AbsorbEnergyGeneState extends GeneState:
	var energy_absorbed:int
	func _init(energy_absorbed_:int):
		energy_absorbed = energy_absorbed_
		
class AbsorbNutrientsGeneConfig extends GeneConfig:
	var energy_per_step:int = 2
	
	func create_gene(cell:Cell, _progenitor:Cell) -> AbsorbNutrientsGene:
		return AbsorbNutrientsGene.new(cell, self)

class AbsorbNutrientsGeneType extends GeneType:
	
	func _init() -> void:
		name = 'AbsorbEnergy'
		energy_cost = 1

	func create_config(_cell_type:CellType) -> AbsorbNutrientsGeneConfig:
		return AbsorbNutrientsGeneConfig.new(self)

static var gene_type_ = AbsorbNutrientsGeneType.new()
