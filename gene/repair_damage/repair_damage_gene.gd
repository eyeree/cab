class_name RepairDamageGene extends Gene

var repaired_amount:int
var repaired_percent:float

func _init(cell_:Cell, config:RepairDamageGeneConfig) -> void:
	super._init(cell_)
	repaired_amount = config.repaired_amount
	repaired_percent = config.repaired_percent
	
func perform_actions() -> void:
	var added_life = min(max_repair_amount, cell.energy)
	#prints('  repair - added_life: %d' % added_life)
	cell.new_life += added_life
	cell.energy -= added_life
	add_state(RepairDamageAction.new(added_life))

func update_state() -> void:
	energy_wanted = max_repair_amount
	
var max_repair_amount:int:
	get: return repaired_amount + roundi(float(cell.max_life) * repaired_percent)
	
class RepairDamageAction extends GeneState:
	var added_life:int
	func _init(added_life_:int) -> void:
		added_life = added_life_
		
class RepairDamageGeneConfig extends GeneConfig:
	
	var repaired_amount:int = 1
	var repaired_percent:float = 0.0

	func create_gene(cell:Cell, _progenitor:Cell) -> RepairDamageGene:
		return RepairDamageGene.new(cell, self)
	
class RepairDamageGeneType extends GeneType:
	
	func _init():
		name = 'RepairDamage'
		energy_cost = 1
	
	func create_config(_cell_type:CellType) -> RepairDamageGeneConfig:
		return RepairDamageGeneConfig.new(self)

static var gene_type_ = RepairDamageGeneType.new()
