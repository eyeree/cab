class_name ResistDamageGeneConfig extends GeneConfig
	
@export var resisted_type:Cell.DamageType = Cell.DamageType.Universal
@export var resisted_amount:int = 0
@export var resisted_percent:float = 0.0

func create_gene(cell:Cell) -> ResistDamageGene:
	return ResistDamageGene.new(cell, self)
	
