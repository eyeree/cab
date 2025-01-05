class_name RepairDamageGene extends Gene

var repaired_amount:int
var repaired_percent:float

func _init(config:RepairDamageGeneConfig) -> void:
	repaired_amount = config.repaired_amount
	repaired_percent = config.repaired_percent
	
func perform_actions(_index:HexIndex, _world:World, cell:Cell) -> void:
	var added_life = min(max_repair_amount(cell), cell.energy)
	cell.new_life += added_life
	cell.energy -= added_life

func update_state(_index:HexIndex, _world:World, cell:Cell) -> void:
	energy_wanted = max_repair_amount(cell)
	
func max_repair_amount(cell:Cell) -> int:
	return repaired_amount + roundi(float(cell.max_life) * repaired_percent)
	
class RepairDamageGeneConfig extends GeneConfig:
	
	var repaired_amount:int = 1
	var repaired_percent:float = 0.0

	func create_gene(_progenitor:Cell) -> RepairDamageGene:
		return RepairDamageGene.new(self)
	
class RepairDamageGeneType extends GeneType:
	
	func _init():
		name = 'RepairDamage'
		energy_cost = 1
	
	func create_config(_cell_type:CellType) -> RepairDamageGeneConfig:
		return RepairDamageGeneConfig.new(self)

static var gene_type:RepairDamageGeneType = RepairDamageGeneType.new()
