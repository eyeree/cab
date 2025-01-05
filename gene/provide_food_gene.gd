class_name ProvideFoodGene extends Gene
	
func _init(_config:ProvideFoodGeneConfig) -> void:
	pass

func perform_actions(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass

class ProvideFoodGeneConfig extends GeneConfig:

	func create_gene(_progenitor:Cell) -> ProvideFoodGene:
		return ProvideFoodGene.new(self)
		
class ProvideFoodGeneType extends GeneType:
	
	func _init():
		name = 'ProvideFood'
		hidden = true

	func create_config(_cell_type:CellType) -> ProvideFoodGeneConfig:
		return ProvideFoodGeneConfig.new(self)

static var gene_type = ProvideFoodGeneType.new()
	
