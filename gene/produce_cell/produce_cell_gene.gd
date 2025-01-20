class_name ProduceCellGene extends Gene
	
var cell_type:CellType
var claimed_index:HexIndex = null
var energy_provided:int = 0
var energy_per_step:int

func _init(cell_:Cell, config:Config):
	super._init(cell_)
	cell_type = config.cell_type
	energy_per_step = config.energy_per_step

func perform_actions() -> void:
	
	if claimed_index == null:
		return
		
	var energy_used:int = min(cell.energy, energy_per_step)
	if energy_used == 0:
		return
		
	cell.energy -= energy_used
	energy_provided += energy_used
	
	var target_cell:Cell = cell.world.get_cell(claimed_index)
	if target_cell == null:
		target_cell = EnvironmentGenome.empty_cell_type.create_cell()
		cell.world.set_cell(claimed_index, target_cell)

	var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
	claimable_cell_gene.add_claim(cell, cell_type, energy_provided)
	
	var state:State = State.new()
	state.cell_type = cell_type
	state.energy_used = energy_used
	state.claimed_index = claimed_index
	add_state(state)
			
func update_state() -> void:
	energy_wanted = 0
	for direction in HexIndex.ALL_DIRECTIONS:
		var target_index:HexIndex = cell.index.neighbor(direction)
		var target_cell:Cell = cell.world.get_cell(target_index)
		if is_claimable(target_cell):
			if claimed_index != target_index:
				energy_provided = 0
				claimed_index = target_index
			energy_wanted = energy_per_step
			break
	if energy_wanted == 0:
		claimed_index = null
			
func is_claimable(target_cell:Cell) -> bool:
	if target_cell != null: 
		var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
		if claimable_cell_gene == null:
			return false
		if not claimable_cell_gene.is_claimable: 
			return false
	return true
		
class State extends GeneState:
	var energy_used:int
	var claimed_index:HexIndex
	var cell_type:CellType
	
class Config extends GeneConfig:
	var cell_type:CellType
	var energy_per_step:int = 1
	
	func _init(gene_type_:GeneType, default_cell_type:CellType) -> void:
		super._init(gene_type_)
		cell_type = default_cell_type
	
	func create_gene(cell:Cell, _progenitor:Cell) -> ProduceCellGene:	
		return ProduceCellGene.new(cell, self)

	func get_energy_cost() -> int:
		return gene_type.energy_cost * energy_per_step

class  Type extends GeneType:
	
	func _init():
		name = 'ProduceCell'
		energy_cost = 1

	func create_config(cell_type:CellType) -> Config:
		return Config.new(self, cell_type)
		
static var gene_type_ = Type.new()
