class_name ProduceToxinGene extends Gene

var damage:int

func _init(config:ProduceToxinGeneConfig) -> void:
	damage = config.damage

func perform_actions(index:HexIndex, world:World, _cell:Cell, cell_state:CellState) -> void:
	var damage_delt:Dictionary[HexIndex, int] = {}
	world.visit_ring(index, 1, 
		func (target_index:HexIndex, target:Cell):
			var actual_damage = target.take_damage(damage, Cell.DamageType.Chemical)
			damage_delt[target_index] = actual_damage
	)
	cell_state.actions.append(ProduceToxinAction.new(damage))
	cell_state.actions.append(Cell.DealDamageAction.new(damage_delt))
	
class ProduceToxinAction extends CellState.Action:
	var damage:int
	func _init(damage_:int):
		damage = damage_
	
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
	
