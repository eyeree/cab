class_name ProvideFoodGene extends Gene

static func _static_init():
	name = 'ProvideFood'
	hidden = true

static func create_config(_cell_type:CellType) -> ProvideFoodGeneConfig:
	return ProvideFoodGeneConfig.new(ProvideFoodGene)

static func create_gene(progenitor:Cell, config:GeneConfig) -> Gene:
	
	if _is_not_config_type(config, ProvideFoodGeneConfig):
		return super.create_gene(progenitor, config)
		
	return ProvideFoodGene.new(config)
	
class ProvideFoodGeneConfig extends GeneConfig:
	pass
	
func _init(_config:ProvideFoodGeneConfig) -> void:
	pass

func perform_actions(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
