class_name ProduceCellGene extends Gene
	
var _cell_type:CellType
var _target_index:HexIndex = null

func _init(cell_:Cell, config:ProduceCellGeneConfig):
	super._init(cell_)
	_cell_type = config.cell_type

func perform_actions() -> void:
	
	if _target_index == null:
		return
	
	if cell.energy < _cell_type.energy_cost:
		return
		
	var target_cell:Cell = cell.world.get_cell(_target_index)
	if target_cell == null:
		target_cell = EnvironmentGenome.empty_cell_type.create_cell()
		cell.world.set_cell(_target_index, target_cell)

	var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
	claimable_cell_gene.add_claim(cell, _cell_type)
	cell.energy -= _cell_type.energy_cost
	
	_target_index = null
			
func update_state() -> void:
	energy_wanted = 0
	_target_index = null
	for direction in HexIndex.ALL_DIRECTIONS:
		var target_index:HexIndex = cell.index.neighbor(direction)
		var target_cell:Cell = cell.world.get_cell(target_index)
		if is_claimable(cell, target_cell):
			_target_index = target_index
			energy_wanted = _cell_type.energy_cost
			break
			
func is_claimable(claiming_cell:Cell, target_cell:Cell) -> bool:
	if target_cell != null: 
		var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
		if claimable_cell_gene == null:
			return false
		if not claimable_cell_gene.is_claimable: 
			return false
		if claimable_cell_gene.is_claimed_by_cell(claiming_cell):
			return false
	return true
		
class ProduceCellGeneConfig extends GeneConfig:
	var cell_type:CellType
	
	func _init(gene_type_:GeneType, default_cell_type:CellType) -> void:
		super._init(gene_type_)
		cell_type = default_cell_type
	
	func create_gene(cell:Cell, _progenitor:Cell) -> ProduceCellGene:	
		return ProduceCellGene.new(cell, self)

class  ProduceCellGeneType extends GeneType:
	
	func _init():
		name = 'ProduceCell'
		energy_cost = 2

	func create_config(cell_type:CellType) -> ProduceCellGeneConfig:
		return ProduceCellGeneConfig.new(self, cell_type)
		
static var gene_type_ = ProduceCellGeneType.new()
