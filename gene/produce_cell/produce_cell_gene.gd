class_name ProduceCellGene extends Gene
	
var energy_per_step:int

var growth_plan:GrowthPlan

var claimed_index:HexIndex = null
var energy_provided:int = 0

func _init(cell_:Cell, config:Config):
	super._init(cell_)
	energy_per_step = config.energy_per_step
	growth_plan = GrowthPlan.from_script(config.growth_plan_script, cell_)

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

	#var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
	#claimable_cell_gene.add_claim(cell, cell_type, energy_provided)
	#
	#var state:State = State.new()
	#state.cell_type = cell_type
	#state.energy_used = energy_used
	#state.claimed_index = claimed_index
	#add_state(state)
			
func update_state() -> void:
	growth_plan._update()
	energy_wanted = energy_per_step if claimed_index else 0
	
	#for direction in HexIndex.ALL_DIRECTIONS:
		#var target_index:HexIndex = cell.index.neighbor(direction)
		#var target_cell:Cell = cell.world.get_cell(target_index)
		#if is_claimable(target_cell):
			#if claimed_index != target_index:
				#energy_provided = 0
				#claimed_index = target_index
			#energy_wanted = energy_per_step
			#break
	#if energy_wanted == 0:
		#claimed_index = null
			
func is_claimable(target_cell:Cell) -> bool:
	if target_cell != null: 
		var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
		if claimable_cell_gene == null:
			return false
		if not claimable_cell_gene.is_claimable: 
			return false
	return true
		
class GrowthPlan:
	
	enum GrowthStatus { GROWING, FAILED, SUCCEEDED }
	
	enum Direction { 
		NE = HexIndex.HexDirection.NE, 
		E  = HexIndex.HexDirection.E, 
		SE = HexIndex.HexDirection.SE, 
		SW = HexIndex.HexDirection.SW, 
		W  = HexIndex.HexDirection.W, 
		NW = HexIndex.HexDirection.NW 
	}
	
	const NE:Direction = Direction.NE
	const E:Direction  = Direction.E
	const SE:Direction = Direction.SE
	const SW:Direction = Direction.SW
	const W:Direction  = Direction.W
	const NW:Direction = Direction.NW
	
	var _gene:ProduceCellGene
	var _cell:Cell
	
	func _init(gene_:ProduceCellGene) -> void:
		_gene = gene_
		_cell = _gene.cell

	func _orient(direction:Direction) -> HexIndex.HexDirection:
		return HexIndex.orient_direction(_cell.orientation, direction as HexIndex.HexDirection)
		
	func _get_cell(direction:Direction) -> Cell:
		return _cell.world.get_cell(_cell.index.neighbor(_orient(direction)))
		
	func _get_claimable_cell_gene(direction:Direction) -> ClaimableCellGene:
		return _get_cell(direction).get_gene(ClaimableCellGene)
		
	func _get_edge_attribute_value(direction:Direction, attribute:StringName) -> float:
		return _cell.get_edge_attribute_value(_orient(direction), attribute)

	func _get_cell_attribute_value(attribute:StringName) -> float:
		return _cell.get_cell_attribute_value(attribute)
			
	func _update() -> void:
		pass
		
	func grow(direction:Direction, cell_type:StringName = "") -> GrowthStatus:
		var target_index:HexIndex = _cell.index.neighbor(_orient(direction))
		var target_cell:Cell = _cell.world.get_cell(target_index)
		#if is_claimable(target_cell):
			#if claimed_index != target_index:
				#energy_provided = 0
				#claimed_index = target_index
		return GrowthStatus.FAILED
		
	func is_empty(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		return claimable_cell_gene and claimable_cell_gene.claims.size() == 0

	func is_growing(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		return claimable_cell_gene and claimable_cell_gene.claims.size() > 0

	func is_growing_self(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		if claimable_cell_gene:
			for claim in claimable_cell_gene.claims:
				if claim.cell_type.genome == _cell.genome:
					return true
		return false

	func is_growing_other(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		if claimable_cell_gene:
			for claim in claimable_cell_gene.claims:
				if claim.cell_type.genome != _cell.genome:
					return true
		return false
		
	func is_growth(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		if claimable_cell_gene:
			for claim in claimable_cell_gene.claims:
				if claim.progenitor == _cell:
					return true
		return false

	func is_self(direction:Direction) -> bool:
		return _get_cell(direction).genome == _cell.genome
		
	func is_other(direction:Direction) -> bool:
		var target_cell := _get_cell(direction)
		return target_cell.genome is not EnvironmentGenome and target_cell.genome != _cell.genome
		
	func is_bounds(direction:Direction) -> bool:
		return _get_cell(direction).cell_type == EnvironmentGenome.bounds_cell_type
		
	static func from_script(script:String, cell:Cell) -> GrowthPlan:
		var cls := _get_growth_plan_class(script)
		return cls.new(cell)
		
	static var _growth_plan_class_map:Dictionary[String, GDScript] = {}
	
	static func _get_growth_plan_class(script:String) -> GDScript:
		var cls:GDScript = _growth_plan_class_map.get(script)
		if cls == null:
			cls = _create_growth_plan_class(script)
			_growth_plan_class_map.set(script, cls)
		return cls	
		
	static func _create_growth_plan_class(script:String) -> GDScript:
		var new_script := GDScript.new()
		new_script.source_code = GROWTH_PLAN_SCRIPT_WRAPPER % _indent_growth_plan_script(script)
		var err := new_script.reload()
		if err != OK:
			push_error("Failed to load growth plan script from string: %d" % [err])
			return GrowthPlan
		return new_script
		
	static func _indent_growth_plan_script(s:String) -> String:
		var result := ''
		for line in s.split('\n'):
			result += '    '
			result += line
		return result	

const DEFAULT_GROWTH_PLAN_SCRIPT = '''
grow(E)
grow(NE)
grow(SE)
grow(NW)
grow(NW)
grow(W)
'''

const GROWTH_PLAN_SCRIPT_WRAPPER = '''
extends GrowthPlan

func _update():
%s
'''

class State extends GeneState:
	var energy_used:int
	var claimed_index:HexIndex
	var cell_type:CellType
	
class Config extends GeneConfig:
	var energy_per_step:int = 1
	var growth_plan_script:String = DEFAULT_GROWTH_PLAN_SCRIPT
	
	func _init(gene_type_:GeneType) -> void:
		super._init(gene_type_)
	
	func create_gene(cell:Cell, _progenitor:Cell) -> ProduceCellGene:	
		return ProduceCellGene.new(cell, self)

	func get_energy_cost() -> int:
		return gene_type.energy_cost * energy_per_step

class  Type extends GeneType:
	
	func _init():
		name = 'ProduceCell'
		energy_cost = 1

	func create_config() -> Config:
		return Config.new(self)
		
static var gene_type_ = Type.new()
