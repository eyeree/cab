class_name ResistDamageGene extends Gene

var resisted_amount:int
var resisted_percent:float
var resisted_type:Cell.DamageType

func _init(config:ResistDamageGeneConfig) -> void:
	resisted_amount = config.resisted_amount
	resisted_percent = config.resisted_percent
	resisted_type = config.resisted_type
	
func damage_resistance(damange_amount:int, damange_type:Cell.DamageType) -> int:
	if damange_type == resisted_type or resisted_type == Cell.DamageType.Universal:
		return resisted_amount + roundi(damange_amount * resisted_percent)
	else:
		return 0

class ResistDamageGeneConfig extends GeneConfig:
	
	var resisted_type:Cell.DamageType = Cell.DamageType.Universal
	var resisted_amount:int = 0
	var resisted_percent:float = 0.0

	func create_gene(_progenitor:Cell) -> ResistDamageGene:
		return ResistDamageGene.new(self)
	
class ResistDamageGeneType extends GeneType:
	
	func _init():
		name = 'ResistDamage'
		energy_cost = 1
	
	func create_config(_cell_type:CellType) -> ResistDamageGeneConfig:
		return ResistDamageGeneConfig.new(self)

static var gene_type:ResistDamageGeneType = ResistDamageGeneType.new()

static var damage_immunity_config:ResistDamageGeneConfig = _get_config_for_damage_immunity()

static func _get_config_for_damage_immunity() -> ResistDamageGeneConfig:
		var config = ResistDamageGeneConfig.new(gene_type)
		config.resisted_type = Cell.DamageType.Universal
		config.resisted_amount = 0
		config.resisted_percent = 1.0
		return config
	
