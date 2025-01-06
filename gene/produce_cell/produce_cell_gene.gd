class_name ProduceCellGene extends Gene
	
var _cell_type:CellType

func _init(config:ProduceCellGeneConfig):
	_cell_type = config.cell_type

func perform_actions(index:HexIndex, world:World, cell:Cell) -> void:
	
	if cell.energy < _cell_type.energy_cost:
		return
		
	var claimable_cell_gene:ClaimableCellGene = _find_claimable_cell(world, index)
	if claimable_cell_gene == null:
		return
		
	cell.energy -= _cell_type.energy_cost
	claimable_cell_gene.add_claim(cell, _cell_type)
			
func _find_claimable_cell(world:World, index:HexIndex) -> ClaimableCellGene:
	for direction in HexIndex.ALL_DIRECTIONS:
		var target_cell:Cell = world.get_cell(index.neighbor(direction))
		var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
		if claimable_cell_gene and claimable_cell_gene.is_claimable:
			return claimable_cell_gene
		#prints('_find_claimable_cell not empty', direction)
	return null
	
func update_state(index:HexIndex, world:World, _cell:Cell) -> void:
	var claimable_cell_gene:ClaimableCellGene = _find_claimable_cell(world, index)
	if claimable_cell_gene == null:
		energy_wanted = 0
	else:
		energy_wanted = _cell_type.energy_cost
		
class ProduceCellGeneConfig extends GeneConfig:
	var cell_type:CellType
	
	func _init(gene_type_:GeneType, default_cell_type:CellType) -> void:
		super._init(gene_type_)
		cell_type = default_cell_type
	
	func create_gene(_progenitor:Cell) -> ProduceCellGene:	
		return ProduceCellGene.new(self)

class  ProduceCellGeneType extends GeneType:
	
	func _init():
		name = 'ProduceCell'
		energy_cost = 2

	func create_config(cell_type:CellType) -> ProduceCellGeneConfig:
		return ProduceCellGeneConfig.new(self, cell_type)
		
static var gene_type_ = ProduceCellGeneType.new()
