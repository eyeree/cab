class_name AbsorbEnergyGene extends Gene
	
var _energy_per_step:int = 0

func _init(config:AbsorbEnergyGeneConfig) -> void:
	_energy_per_step = config.energy_per_step

func perform_actions(_index:HexIndex, _world:World, cell:Cell) -> void:
	cell.new_energy += _energy_per_step
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass

class AbsorbEnergyGeneConfig extends GeneConfig:
	var energy_per_step:int = 2
	
	func create_gene(_progenitor:Cell) -> AbsorbEnergyGene:
		return AbsorbEnergyGene.new(self)

class AbsorbEnergyGeneType extends GeneType:
	
	func _init() -> void:
		name = 'AbsorbEnergy'
		energy_cost = 1

	func create_config(_cell_type:CellType) -> AbsorbEnergyGeneConfig:
		return AbsorbEnergyGeneConfig.new(self)

static var gene_type_ = AbsorbEnergyGeneType.new()
