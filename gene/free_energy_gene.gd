class_name FreeEnergyGene extends Gene
	
var _energy_per_step:int = 0

func _init(config:FreeEnergyGeneConfig) -> void:
	_energy_per_step = config.energy_per_step

func perform_actions(_index:HexIndex, _world:World, cell:Cell) -> void:
	cell.new_energy += _energy_per_step
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass

class FreeEnergyGeneConfig extends GeneConfig:
	var energy_per_step:int = 2
	
	func create_gene(_progenitor:Cell) -> FreeEnergyGene:
		return FreeEnergyGene.new(self)

class FreeEnergyGeneType extends GeneType:
	
	func _init() -> void:
		name = 'FreeEnergy'
		energy_cost = 2

	func create_config(_cell_type:CellType) -> FreeEnergyGeneConfig:
		return FreeEnergyGeneConfig.new(self)

static var gene_type = FreeEnergyGeneType.new()
