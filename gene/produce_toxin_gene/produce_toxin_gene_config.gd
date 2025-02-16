class_name ProduceToxinGeneConfig extends GeneConfig
	
@export var damage:int = 1

func create_gene(cell:Cell) -> ProduceToxinGene:
	return ProduceToxinGene.new(cell, self)
