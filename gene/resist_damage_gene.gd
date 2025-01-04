class_name ResistDamageGene extends Gene

static func _static_init():
	name = 'ResistDamage'
	
static func create_config(_cell_type:CellType) -> ResistDamageGeneConfig:
	return ResistDamageGeneConfig.new()

static func create_gene(progenitor:Cell, config:GeneConfig) -> Gene:
	
	if _is_not_config_type(config, ResistDamageGeneConfig):
		return super.create_gene(progenitor, config)
		
	return ProduceCellGene.new(config)
	
class ResistDamageGeneConfig extends GeneConfig:
	var resisted_type:Cell.DamageType
	var resisted_amount:float
	
	func _init(
		resisted_amount_:float = 1.0, 
		resisted_type_:Cell.DamageType = Cell.DamageType.Universal
	):
		super._init(ResistDamageGene)
		resisted_amount = resisted_amount_
		resisted_type = resisted_type_
	
var resisted_amount:float
var resisted_type:Cell.DamageType

func _init(config:ResistDamageGeneConfig) -> void:
	resisted_amount = config.resisted_amount
	resisted_type = config.resisted_type
	
func damage_resistance(_damange_amount:float, damange_type:Cell.DamageType) -> float:
	if damange_type == resisted_type or resisted_type == Cell.DamageType.Universal:
		return resisted_amount
	else:
		return 0

static var damage_immunity = ResistDamageGeneConfig.new(
	INF, Cell.DamageType.Universal
)
