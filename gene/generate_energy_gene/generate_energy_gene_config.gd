class_name GenerateEnergyGeneConfig extends GeneConfig

@export var energy_per_step:int = 1

func create_gene(cell:Cell) -> GenerateEnergyGene:
	return GenerateEnergyGene.new(cell, self)

func get_energy_cost() -> int:
	return gene_type.energy_cost * energy_per_step
