class_name ProduceCellGene extends Gene
	
var energy_per_step:int
var growth_plan:GrowthPlan
var claims:Dictionary[ClaimableCellGene, ClaimableCellGene.Claim] = {}

func _init(cell_:Cell, config:Config):
	super._init(cell_)
	energy_per_step = config.energy_per_step
	growth_plan = GrowthPlan.from_script(config.growth_plan_script, self)

func perform_actions() -> void:
	
	if claims.size() == 0:
		return
		
	var energy_used:int = min(cell.energy, energy_per_step)
	if energy_used == 0:
		return

	cell.energy -= energy_used
		
	var energy_per_claim:float = float(energy_used) / claims.size()
	
	for claim in claims.values():
		claim.energy_provided += energy_per_claim
		
	var state:State = State.new()
	state.energy_used = energy_used
	state.energy_per_claim = energy_per_claim
	#state.claims = claims.duplicate()
	add_state(state)
			
func update_state() -> void:
	growth_plan._update_state()
	energy_wanted = energy_per_step if claims.size() > 0 else 0
		
class GrowthPlan:
	
	enum Direction { 
		E  = HexIndex.HexDirection.E, 
		SE = HexIndex.HexDirection.SE, 
		SW = HexIndex.HexDirection.SW, 
		W  = HexIndex.HexDirection.W, 
		NW = HexIndex.HexDirection.NW,
		NE = HexIndex.HexDirection.NE, 
	}
	
	const E:Direction  = Direction.E
	const SE:Direction = Direction.SE
	const SW:Direction = Direction.SW
	const W:Direction  = Direction.W
	const NW:Direction = Direction.NW
	const NE:Direction = Direction.NE
	
	var _gene:ProduceCellGene
	var _cell:Cell
	var _world:World:
		get: return _cell.world
		
	var _grow_results:Array[GrowResult] = []
	var _first_update := true
	
	func _init(gene_:ProduceCellGene) -> void:
		_gene = gene_
		_cell = _gene.cell

	func _orient(direction:Direction) -> HexIndex.HexDirection:
		#prints("_orient", _cell.orientation, '+', direction, '->', HexIndex.orient_direction(_cell.orientation, direction as HexIndex.HexDirection))
		return HexIndex.orient_direction(_cell.orientation, direction as HexIndex.HexDirection)
		
	func _get_cell(direction:Direction) -> Cell:
		return _world.get_cell(_cell.index.neighbor(_orient(direction)))
		
	func _get_claimable_cell_gene(direction:Direction) -> ClaimableCellGene:
		return _get_cell(direction).get_gene(ClaimableCellGene)
		
	func _get_edge_attribute_value(direction:Direction, attribute:StringName) -> float:
		return _cell.get_edge_attribute_value(_orient(direction), attribute)

	func _get_cell_attribute_value(attribute:StringName) -> float:
		return _cell.get_cell_attribute_value(attribute)
			
	func _update_state() -> void:
		if _first_update:
			_start_growing()
			_first_update = false
		else:
			for grow_result in _grow_results:
				grow_result._update_state()
			_grow_results.assign(
				_grow_results.filter(
					func (grow_result:GrowResult): 
						return grow_result._is_pending))
				
	func _start_growing() -> void:
		pass
		
	func grow(direction:Direction, cell_type_name:StringName = "") -> GrowResult:
		var grow_result:GrowResult = null
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		if claimable_cell_gene:
			var cell_type := _cell.genome.get_cell_type(cell_type_name) \
				if cell_type_name != "" else _cell.cell_type
			if cell_type == null:
				prints("Missing cell type:", cell_type_name)
			else:
				var claim:ClaimableCellGene.Claim = _gene.claims.get(claimable_cell_gene)
				if claim: claim.cancel()
				claim = claimable_cell_gene.add_claim(_cell, cell_type)
				_gene.claims.set(claimable_cell_gene, claim)
				claim.completed.connect(
					func (_successful:bool):	
						_gene.claims.erase(claimable_cell_gene))
				grow_result = GrowResult.new(claim)
		if grow_result == null:
			grow_result = GrowResult.new(null)
		_grow_results.append(grow_result)
		return grow_result
		
	class GrowResult:
		
		enum Status { PENDING, SUCCEEDED, FAILED }
		
		var _claim:ClaimableCellGene.Claim
		var _failed_callable:Callable
		var _succeeded_callable:Callable
		var _status := Status.PENDING
		
		func _init(claim:ClaimableCellGene.Claim) -> void:
			_claim = claim
			if _claim:
				_claim.completed.connect(func (successful:bool):
					_status = Status.SUCCEEDED if successful else Status.FAILED
				)
			else:
				_status = Status.FAILED
		
		func failed(callable:Callable) -> void:
			_failed_callable = callable
		
		func succecced(callable:Callable) -> void:
			_succeeded_callable = callable
			
		func stop() -> void:
			_claim.cancel()
			
		func _update_state() -> void:
			match _status:
				Status.SUCCEEDED:
					if _succeeded_callable:
						_succeeded_callable.call()
				Status.FAILED:
					if _failed_callable:
						_failed_callable.call()
						
		var _is_pending:bool:
			get: return _status == Status.PENDING
		
	func is_empty(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		return claimable_cell_gene and claimable_cell_gene.claims.size() == 0

	func is_growing(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		return claimable_cell_gene and claimable_cell_gene.is_claimable and claimable_cell_gene.claims.size() > 0

	func is_growing_self(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		if claimable_cell_gene and claimable_cell_gene.is_claimable:
			for claim in claimable_cell_gene.claims:
				if claim.cell_type.genome == _cell.genome:
					return true
		return false

	func is_growing_other(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		if claimable_cell_gene and claimable_cell_gene.is_claimable:
			for claim in claimable_cell_gene.claims:
				if claim.cell_type.genome != _cell.genome:
					return true
		return false
		
	func is_growth(direction:Direction) -> bool:
		var claimable_cell_gene := _get_claimable_cell_gene(direction)
		if claimable_cell_gene and claimable_cell_gene.is_claimable:
			for claim in claimable_cell_gene.claims:
				if claim.progenitor == _cell:
					return true
		return false

	func is_self(direction:Direction) -> bool:
		return _get_cell(direction).genome == _cell.genome
		
	func is_other(direction:Direction) -> bool:
		var target_cell := _get_cell(direction)
		return target_cell.genome != _world.environment_genome and target_cell.genome != _cell.genome
		
	func is_bounds(direction:Direction) -> bool:
		return _get_cell(direction).cell_type == _world.environment_genome.bounds_cell_type
		
	static func from_script(script:String, gene:ProduceCellGene) -> GrowthPlan:
		var cls := _get_growth_plan_class(script)
		return cls.new(gene)
		
	static var _growth_plan_class_map:Dictionary[String, GDScript] = {}
	
	static func _get_growth_plan_class(script:String) -> GDScript:
		return SpiralGrowthPlan
		var cls:GDScript = _growth_plan_class_map.get(script)
		if cls == null:
			cls = _create_growth_plan_class(script)
			_growth_plan_class_map.set(script, cls)
		return cls	

	class SpiralGrowthPlan extends GrowthPlan:	
		func _start_growing():			
			grow(SW).failed(
				func (): grow(SE).failed(
					func (): grow(E)
				)
			)

	class StraightOrSplitGrowthPlan extends GrowthPlan:	
		func _start_growing():			
			grow(E).failed(
				func ():
					grow(NE)
					grow(SE)
			)

	class StraightGrowthPlan extends GrowthPlan:
		func _start_growing():			
			grow(E)
	
	static func _create_growth_plan_class(script:String) -> GDScript:
		var new_script := GDScript.new()
		new_script.source_code = GROWTH_PLAN_SCRIPT_WRAPPER % _indent_growth_plan_script(script)
		var err := new_script.reload()
		if err != OK:
			push_error("Failed to load growth plan script from string: %d" % [err])
			prints('--- source code ---')
			prints(new_script.source_code)
			prints('-------------------')
			return GrowthPlan
		return new_script
		
	static func _indent_growth_plan_script(s:String) -> String:
		var result := ''
		for line in s.split('\n'):
			result += '\t'
			result += line
			result += '\n'
		return result	

const DEFAULT_GROWTH_PLAN_SCRIPT = '''
#grow(E)
#grow(NE)
if not grow(SE):
	grow(E)
#grow(NW)
#grow(SW)
#grow(W)
'''

const GROWTH_PLAN_SCRIPT_WRAPPER = '''
extends ProduceCellGene.GrowthPlan

func _start_growing():
%s
'''

class State extends GeneState:
	var energy_used:int
	var energy_per_claim:float
	var claims:Array[ClaimableCellGene.Claim]
	
class Config extends GeneConfig:
	var energy_per_step:int = 1
	var growth_plan_script:String = DEFAULT_GROWTH_PLAN_SCRIPT
	
	func create_gene(cell:Cell, _progenitor:Cell) -> ProduceCellGene:	
		return ProduceCellGene.new(cell, self)

	func get_energy_cost() -> int:
		return gene_type.energy_cost * energy_per_step

class Type extends GeneType:
	
	func _init():
		name = 'ProduceCell'
		energy_cost = 1

	func create_config() -> Config:
		return Config.new(self)
		
static var gene_type_ = Type.new()
