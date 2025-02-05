class_name ProduceCellGene extends Gene
	
var energy_per_step:int

var growth_plan:GrowthPlan
var active_production_plans:Array[GrowthPlanProduce] = []
var growth_plans_complete:Array[GrowthPlan] = []

var claimed_index:HexIndex = null
var energy_provided:int = 0

func _init(cell_:Cell, config:Config):
	super._init(cell_)
	energy_per_step = config.energy_per_step
	growth_plan = config.growth_plan

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
	energy_wanted = 0
	
	active_production_plans.clear()
	
	var context:ConditionContext = ConditionContext.new(self.cell)
	if growth_plan.is_enabled(context):
		growth_plan.add_production_plans(context, active_production_plans)
	
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
		
class ConditionContext:
	
	var cell:Cell
	
	var world:World:
		get: return cell.world

	var index:HexIndex:
		get: return cell.index
	
	func _init(cell_:Cell) -> void:
		cell = cell_
		
	func get_edge_attribute_value(direction:HexIndex.HexDirection, attribute:StringName) -> float:
		var oriented_direction = HexIndex.orient_direction(cell.orientation, direction)
		return cell.get_edge_attribute_value(oriented_direction, attribute)

	func get_cell_attribute_value(attribute:StringName) -> float:
		return cell.get_cell_attribute_value(attribute)
		
class Condition:
	func evaluate(context:ConditionContext) -> bool:
		return false
	
class ConditionEdgeThreshold:
	var direction:HexIndex.HexDirection
	var attribute:StringName
	var threshold:float
	func evaluate(context:ConditionContext) -> bool:
		return context.get_edge_attribute_value(direction, attribute) >= threshold

class ConditionCellThreshold:
	var attribute:StringName
	var threshold:float
	func evaluate(context:ConditionContext) -> bool:
		return context.get_cell_attribute_value(attribute) >= threshold

class ConditionAnd:
	var a:Condition
	var b:Condition
	func evaluate(context:ConditionContext) -> bool:
		return a.evaluate(context) and b.evaluate(context)

class ConditionOr:
	var a:Condition
	var b:Condition
	func evaluate(context:ConditionContext) -> bool:
		return a.evaluate(context) or b.evaluate(context)

class ConditionNot:
	var a:Condition
	func evaluate(context:ConditionContext) -> bool:
		return not a.evaluate(context)
		
class ConditionTrue:
	func evaluate(context:ConditionContext) -> bool:
		return true
	
class ConditionFalse:
	func evaluate(context:ConditionContext) -> bool:
		return false
			
class GrowthPlan:
	var condition:Condition
	
	func is_enabled(context:ConditionContext) -> bool:
		return condition.evaluate(context)
			
	func add_production_plans(context:ConditionContext, production_plans:Array[GrowthPlanProduce]) -> void:
		pass

	
class GrowthPlanProduce extends GrowthPlan:
	var direction:HexIndex.HexDirection
	var cell_type:CellType
	
	func _init(direction_:HexIndex.HexDirection = HexIndex.HexDirection.E, cell_type_:CellType = null) -> void:
		direction = direction_
		cell_type = cell_type_
	
	func is_claimable(target_cell:Cell) -> bool:
		if target_cell == null:
			return true
		var claimable_cell_gene:ClaimableCellGene = target_cell.get_gene(ClaimableCellGene)
		if claimable_cell_gene != null and claimable_cell_gene.is_claimable:
			return true
		return false
				
	func add_production_plans(context, production_plans) -> void:
		var oriented_direction:HexIndex.HexDirection = HexIndex.orient_direction(context.cell.orientation, direction)
		var target_cell:Cell = context.world.get_cell(context.index.neighbor(oriented_direction))
		if is_claimable(target_cell):
			production_plans.append(self)

class GrowthPlanSequence extends GrowthPlan:
	var growth_plans:Array[GrowthPlan] = []
	func add_production_plans(context, production_plans) -> void:
		for growth_plan:GrowthPlan in growth_plans:
			if not context.cell.growth_plans_complete.has(growth_plan) and growth_plan.is_enabled(context):
				growth_plan.add_production_plans(context, production_plans)
				break
		
class GrowthPlanParallel extends GrowthPlan:
	var growth_plans:Array[GrowthPlan]
	func add_production_plans(context, production_plans) -> void:
		for growth_plan:GrowthPlan in growth_plans:
			if growth_plan.is_enabled(context):
				growth_plan.add_production_plans(context, production_plans)

class GrowthPlanFirst extends GrowthPlan:
	var growth_plans:Array[GrowthPlan]
	func add_production_plans(context, production_plans) -> void:
		for growth_plan:GrowthPlan in growth_plans:
			if context.cell.growth_plans_complete.has(growth_plan):
				break
			if growth_plan.is_enabled(context):
				growth_plan.add_production_plans(context, production_plans)
				break

class State extends GeneState:
	var energy_used:int
	var claimed_index:HexIndex
	var cell_type:CellType
	
class Config extends GeneConfig:
	var energy_per_step:int = 1
	var growth_plan:GrowthPlan = GrowthPlanProduce.new()
	
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
