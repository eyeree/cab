class_name ProduceToxinGene extends Gene

var damage:int

func _init(cell_:Cell, config:ProduceToxinGeneConfig) -> void:
	super._init(cell_)
	damage = config.damage

func perform_actions() -> void:
	var damage_delt:Dictionary[HexIndex, int] = {}
	cell.world.visit_ring(cell.index, 1, 
		func (target_index:HexIndex, target:Cell):
			var actual_damage = target.take_damage(cell.index, damage, Cell.DamageType.Chemical)
			damage_delt[target_index] = actual_damage
	)
	cell.state.set_gene_state(ProduceToxinGeneState.new(damage, damage_delt))
	
class ProduceToxinGeneState extends GeneState:
	var damage:int
	var damage_delt:Dictionary[HexIndex, int]
	func _init(damage_:int, damage_delt_:Dictionary[HexIndex, int]):
		damage = damage_
		damage_delt = damage_delt_
	
class ProduceToxinGeneConfig extends GeneConfig:
	
	@export var damage:int = 1
	
	func create_gene(cell:Cell, _progenitor:Cell) -> ProduceToxinGene:
		return ProduceToxinGene.new(cell, self)
		
class ProduceToxinGeneType extends GeneType:

	func _init():
		name = 'ProduceToxin'
	
	func create_config() -> ProduceToxinGeneConfig:
		return ProduceToxinGeneConfig.new(self)

static var gene_type_ = ProduceToxinGeneType.new()
	
