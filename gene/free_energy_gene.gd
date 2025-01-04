class_name FreeEnergyGene extends Gene

static func _static_init():
	name = 'FreeEnergy'
	
static func create_config(cell_type:CellType) -> FreeEnergyGeneConfig:
	return FreeEnergyGeneConfig.new(FreeEnergyGene)

static func create_gene(progenitor:Cell, config:GeneConfig) -> Gene:
	
	if _is_not_config_type(config, FreeEnergyGeneConfig):
		return super.create_gene(progenitor, config)
		
	return ProduceCellGene.new(config)
	
class FreeEnergyGeneConfig extends GeneConfig:
	var energy_per_step:int = 1
	
var _energy_per_step:int = 0

func _init(config:FreeEnergyGeneConfig) -> void:
	_energy_per_step = config.energy_per_step

func perform_actions(index:HexIndex, world:World, cell:Cell) -> void:
	cell.new_energy += _energy_per_step
				
func update_state(index:HexIndex, world:World, cell:Cell) -> void:
	pass
