class_name ClaimableCellGeneConfig extends GeneConfig
		
func create_gene(cell:Cell) -> ClaimableCellGene:
	return ClaimableCellGene.new(cell)
