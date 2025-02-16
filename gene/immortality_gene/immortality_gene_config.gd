class_name ImmortalityGeneConfig extends GeneConfig
	
func create_gene(cell:Cell) -> ImmortalityGene:
	return ImmortalityGene.new(cell)
