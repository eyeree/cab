class_name ProvideFoodGene extends Gene
	
func _init(cell_:Cell, _config:ProvideFoodGeneConfig) -> void:
	super._init(cell_)

class ProvideFoodGeneConfig extends GeneConfig:
	func create_gene(cell:Cell, _progenitor:Cell) -> ProvideFoodGene:
		return ProvideFoodGene.new(cell, self)
		
class ProvideFoodGeneType extends GeneType:
	
	func _init():
		name = 'ProvideFood'
		hidden = true

	func create_config(_cell_type:CellType) -> ProvideFoodGeneConfig:
		return ProvideFoodGeneConfig.new(self)

static var gene_type_ = ProvideFoodGeneType.new()
	
