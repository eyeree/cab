		
class_name RepairDamageGeneConfig extends GeneConfig
	
@export var max_repaired_amount:int = 1

func create_gene(cell:Cell) -> RepairDamageGene:
	return RepairDamageGene.new(cell, self)

func get_energy_cost() -> int:
	return gene_type.energy_cost * max_repaired_amount
