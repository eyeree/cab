class_name AbsorbNutrientsGene extends Gene
	
var _energy_per_step:int = 0

func _init(config:AbsorbNutrientsGeneConfig) -> void:
	_energy_per_step = config.energy_per_step

func perform_actions(_index:HexIndex, _world:World, cell:Cell, cell_state:CellState) -> void:
	cell.new_energy += _energy_per_step
	cell_state.add_action(AbsorbEnergyAction.new(_energy_per_step))
				
func update_state(_index:HexIndex, _world:World, _cell:Cell, _cell_history:CellState) -> void:
	pass

class AbsorbEnergyAction extends CellState.Action:
	var energy_absorbed:int
	func _init(energy_absorbed_:int):
		energy_absorbed = energy_absorbed_
		
class AbsorbNutrientsGeneConfig extends GeneConfig:
	var energy_per_step:int = 2
	
	func create_gene(_progenitor:Cell) -> AbsorbNutrientsGene:
		return AbsorbNutrientsGene.new(self)

class AbsorbNutrientsGeneType extends GeneType:
	
	func _init() -> void:
		name = 'AbsorbEnergy'
		energy_cost = 1

	func create_config(_cell_type:CellType) -> AbsorbNutrientsGeneConfig:
		return AbsorbNutrientsGeneConfig.new(self)

static var gene_type_ = AbsorbNutrientsGeneType.new()
