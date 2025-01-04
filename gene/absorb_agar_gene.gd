class_name AbsorbAgarGene extends Gene

static func _static_init():
	name = 'AbsorbAgar'
	
static func create_config(cell_type:CellType) -> AbsorbAgarGeneConfig:
	return AbsorbAgarGeneConfig.new(AbsorbAgarGene)

static func create_gene(progenitor:Cell, config:GeneConfig) -> Gene:
	
	if _is_not_config_type(config, AbsorbAgarGeneConfig):
		return super.create_gene(progenitor, config)
		
	return ProduceCellGene.new(config)
	
class AbsorbAgarGeneConfig extends GeneConfig:
	var energy_per_cell:int = 5
	
var _energy_per_cell:int = 0

func _init(config:AbsorbAgarGeneConfig) -> void:
	_energy_per_cell = config.energy_per_cell

func perform_actions(index:HexIndex, world:World, cell:Cell) -> void:
	world.visit_ring(index, 1, 
		func (index:HexIndex, cell:Cell):
			if cell.has_gene(ProvideAgarGene):
				cell.new_energy += _energy_per_cell
	)
				
func update_state(index:HexIndex, world:World, cell:Cell) -> void:
	pass
