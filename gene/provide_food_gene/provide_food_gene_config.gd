class_name ProvideFoodGeneConfig extends GeneConfig

func create_gene(cell:Cell) -> ProvideFoodGene:
	return ProvideFoodGene.new(cell, self)
