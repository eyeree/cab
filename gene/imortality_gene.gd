class_name ImortalityGene extends Gene

func _init(_config:ImortalityGeneConfig) -> void:
	pass
	
func apply_damage_resistance(damange_amount:int, _damange_type:Cell.DamageType) -> int:
	return damange_amount

class ImortalityGeneConfig extends GeneConfig:
	
	func create_gene(_progenitor:Cell) -> ImortalityGene:
		return ImortalityGene.new(self)
	
class ImortalityGeneType extends GeneType:
	
	func _init():
		name = 'Imortality'
		energy_cost = 1
		hidden = true
	
	func create_config(_cell_type:CellType) -> ImortalityGeneConfig:
		return ImortalityGeneConfig.new(self)

static var gene_type:ImortalityGeneType = ImortalityGeneType.new()
