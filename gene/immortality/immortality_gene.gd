class_name ImmortalityGene extends Gene

func apply_damage_resistance(_source_index:HexIndex, damage_amount:int, _damage_type:Cell.DamageType) -> int:
	return damage_amount

class ImmortalityGeneConfig extends GeneConfig:
	
	func create_gene(cell:Cell, _progenitor:Cell) -> ImmortalityGene:
		return ImmortalityGene.new(cell)
	
class ImmortalityGeneType extends GeneType:
	
	func _init():
		name = 'Immortality'
		energy_cost = 1
		hidden = true
	
	func create_config(_cell_type:CellType) -> ImmortalityGeneConfig:
		return ImmortalityGeneConfig.new(self)

static var gene_type_ = ImmortalityGeneType.new()
