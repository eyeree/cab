class_name ProduceCellGeneConfig extends GeneConfig
	
@export var energy_per_step:int = 1
@export var growth_plan_script:String = GrowthPlan.DEFAULT_GROWTH_PLAN_SCRIPT

func create_gene(cell:Cell) -> ProduceCellGene:	
	return ProduceCellGene.new(cell, self)

func get_energy_cost() -> int:
	return gene_type.energy_cost * energy_per_step
