class_name ProduceCellGene extends Gene
	
var _cell_type:CellType
var _claimed_index:HexIndex = null
var _claimable_cell_gene:ClaimableCellGene = null

func _init(config:ProduceCellGeneConfig):
	_cell_type = config.cell_type

func perform_actions(index:HexIndex, world:World, cell:Cell, cell_history:Dictionary) -> void:
	
	if _claimed_index == null:
		return
	
	if cell.energy < _cell_type.energy_cost:
		return
		
	cell.energy -= _cell_type.energy_cost
	_claimable_cell_gene.add_claim(cell, _cell_type)
	
	_claimed_index = null
	_claimable_cell_gene = null
	
	cell_history['claim_cell'] = { 
		claimed_index = _claimed_index,
		cell_type = _cell_type
	}
			
func update_state(index:HexIndex, world:World, _cell:Cell, cell_history:Dictionary) -> void:
	energy_wanted = 0
	for direction in HexIndex.ALL_DIRECTIONS:
		var target_index:HexIndex = index.neighbor(direction)
		var target_cell:Cell = world.get_cell(target_index)
		if target_cell == null:
			target_cell = EnvironmentGenome.empty_cell_type.create_cell()
			world.set_cell(target_index, target_cell)
		var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
		if claimable_cell_gene and claimable_cell_gene.is_claimable:
			_claimed_index = target_index
			_claimable_cell_gene = claimable_cell_gene
			cell_history['target_cell'] = {
				target_index = target_index,
				cell_type = _cell_type
			}
			energy_wanted = _cell_type.energy_cost
			break
		
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
