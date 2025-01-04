class_name ProduceCellGene extends Gene
	
static func _static_init():
	name = 'ProduceCell'
	
static func create_config(cell_type:CellType) -> ProduceCellGeneConfig:
	return ProduceCellGeneConfig.new(cell_type)

static func create_gene(progenitor:Cell, config:GeneConfig) -> Gene:
	
	if config is not ProduceCellGeneConfig:
		push_error('wrong config type passed to gene %s create_state: %s' % [name, config])
		return super.create_gene(progenitor, config)
		
	return ProduceCellGene.new(config)
	
class ProduceCellGeneConfig extends GeneConfig:
	var cell_type:CellType
	var directions:Array[HexIndex.HexDirection] = HexIndex.ALL_DIRECTIONS.duplicate()
	
	func _init(cell_type_:CellType):
		cell_type = cell_type_
	
var _cell_type:CellType
var _directions:Array[HexIndex.HexDirection]

func _init(config:ProduceCellGeneConfig):
	_cell_type = config.cell_type
	_directions = config.directions

func perform_actions(index:HexIndex, world:World, cell:Cell) -> void:
	if cell.energy >= _cell_type.energy_cost:
		var claimable_cell_gene:ClaimableCellGene = _find_claimable_cell(world, index)
		if claimable_cell_gene:
			cell.energy -= _cell_type.energy_cost
			claimable_cell_gene.add_claim(cell, _cell_type)
			
func _find_claimable_cell(world:World, index:HexIndex) -> ClaimableCellGene:
	for direction in _directions:
		var target_cell:Cell = world.get_cell(index.neighbor(direction))
		var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
		if claimable_cell_gene:
			return claimable_cell_gene
	return null
	
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
