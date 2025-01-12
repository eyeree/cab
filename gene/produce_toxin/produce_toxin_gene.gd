class_name ProduceToxinGene extends Gene

var damage:int

func _init(config:ProduceToxinGeneConfig) -> void:
	damage = config.damage

func perform_actions(index:HexIndex, world:World, _cell:Cell, cell_history:Dictionary) -> void:
	var damage_delt:Dictionary = {}
	world.visit_ring(index, 1, 
		func (index:HexIndex, target:Cell):
			var actual_damage = target.take_damage(damage, Cell.DamageType.Chemical)
			damage_delt[index] = actual_damage
	)
	cell_history['produce_toxin'] = damage
	cell_history['damage_delt'] = damage_delt

class ProduceToxinGeneConfig extends GeneConfig:
	
	var damage:int = 1
	
	func create_gene(_progenitor:Cell) -> ProduceToxinGene:
		return ProduceToxinGene.new(self)
		
class ProduceToxinGeneType extends GeneType:

	func _init():
		name = 'ProduceToxin'
	
	func create_config(_cell_type:CellType) -> ProduceToxinGeneConfig:
		return ProduceToxinGeneConfig.new(self)

static var gene_type_ = ProduceToxinGeneType.new()
	
