class_name ProduceToxinGene extends Gene

var damage:int

func _init(config:ProduceToxinGeneConfig) -> void:
	damage = config.damage

func perform_actions(index:HexIndex, world:World, _cell:Cell) -> void:
	world.visit_ring(index, 1, 
		func (_index:HexIndex, target:Cell):
			target.take_damage(damage, Cell.DamageType.Chemical)
	)
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass

class ProduceToxinGeneConfig extends GeneConfig:
	
	var damage:int = 1
	
	func create_gene(_progenitor:Cell) -> ProduceToxinGene:
		return ProduceToxinGene.new(self)
		
class ProduceToxinGeneType extends GeneType:

	func _init():
		name = 'ProduceToxin'
	
	func create_config(_cell_type:CellType) -> ProduceToxinGeneConfig:
		return ProduceToxinGeneConfig.new(self)

static var gene_type = ProduceToxinGeneType.new()
	
