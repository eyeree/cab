class_name ProvideAgarGene extends Gene

static func _static_init():
	name = 'ProvideAgar'
	hidden = true
	
static func create_config(_cell_type:CellType) -> ProvideAgarGeneConfig:
	return ProvideAgarGeneConfig.new(ProvideAgarGene)

static func create_gene(progenitor:Cell, config:GeneConfig) -> Gene:
	
	if _is_not_config_type(config, ProvideAgarGeneConfig):
		return super.create_gene(progenitor, config)
		
	return ProvideAgarGene.new(config)
	
class ProvideAgarGeneConfig extends GeneConfig:
	pass
	
func _init(_config:ProvideAgarGeneConfig) -> void:
	pass

func perform_actions(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
