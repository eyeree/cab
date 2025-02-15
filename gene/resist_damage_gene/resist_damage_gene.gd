class_name ResistDamageGene extends Gene

var resisted_amount:int
var resisted_percent:float
var resisted_type:Cell.DamageType

func _init(cell_:Cell, config:ResistDamageGeneConfig) -> void:
	super._init(cell_)
	resisted_amount = config.resisted_amount
	resisted_percent = config.resisted_percent
	resisted_type = config.resisted_type
	
func apply_damage_resistance(source_index:HexIndex, damage_amount:int, damange_type:Cell.DamageType) -> int:
	if damange_type == resisted_type or resisted_type == Cell.DamageType.Universal:
		var resisted_damage:int = max(damage_amount, resisted_amount + roundi(damage_amount * resisted_percent))
		add_state(ResistDamageGeneState.new(source_index, resisted_damage, damange_type))
		return resisted_damage
	else:
		return 0

class ResistDamageGeneState extends GeneState:
	var source_index:HexIndex
	var resisted_damage:int
	var resisted_damage_type:Cell.DamageType
	func _init(source_index_:HexIndex, resisted_damage_:int, resisted_damage_type_:Cell.DamageType) -> void:
		source_index = source_index_
		resisted_damage = resisted_damage_
		resisted_damage_type = resisted_damage_type_
		
class ResistDamageGeneConfig extends GeneConfig:
	
	@export var resisted_type:Cell.DamageType = Cell.DamageType.Universal
	@export var resisted_amount:int = 0
	@export var resisted_percent:float = 0.0

	func create_gene(cell:Cell, _progenitor:Cell) -> ResistDamageGene:
		return ResistDamageGene.new(cell, self)
	
class ResistDamageGeneType extends GeneType:
	
	func _init():
		name = 'ResistDamage'
		energy_cost = 1
	
	func create_config() -> ResistDamageGeneConfig:
		return ResistDamageGeneConfig.new(self)

static var gene_type_ = ResistDamageGeneType.new()

static var damage_immunity_config:ResistDamageGeneConfig = _get_config_for_damage_immunity()

static func _get_config_for_damage_immunity() -> ResistDamageGeneConfig:
		var config = ResistDamageGeneConfig.new(gene_type_)
		config.resisted_type = Cell.DamageType.Universal
		config.resisted_amount = 0
		config.resisted_percent = 1.0
		return config
	
