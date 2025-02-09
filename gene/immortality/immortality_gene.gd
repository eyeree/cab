class_name ImmortalityGene extends Gene

func init_cell():
	cell.immortal = true

class Config extends GeneConfig:
	
	func create_gene(cell:Cell, _progenitor:Cell) -> ImmortalityGene:
		return ImmortalityGene.new(cell)
	
class Type extends GeneType:
	
	func _init():
		name = 'Immortality'
		energy_cost = 1
		hidden = true
	
	func create_config() -> Config:
		return Config.new(self)

static var gene_type_ = Type.new()
