class_name ProduceToxinGene extends Gene

static func _static_init():
	name = 'ProduceToxin'
	
static func create_config(_cell_type:CellType) -> ProduceToxinGeneConfig:
	return ProduceToxinGeneConfig.new(ProduceToxinGene)

static func create_gene(progenitor:Cell, config:GeneConfig) -> Gene:
	
	if _is_not_config_type(config, ProduceToxinGeneConfig):
		return super.create_gene(progenitor, config)
		
	return ProduceCellGene.new(config)
	
class ProduceToxinGeneConfig extends GeneConfig:
	var damage:float = 1.0
	
var damage:float

func _init(config:ProduceToxinGeneConfig) -> void:
	damage = config.damage

func perform_actions(index:HexIndex, world:World, _cell:Cell) -> void:
	world.visit_ring(index, 1, 
		func (_index:HexIndex, target:Cell):
			target.take_damage(damage, Cell.DamageType.Chemical)
	)
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
