class_name ProduceCellGene extends Gene
	
var energy_per_step:int
var growth_plan:GrowthPlan
var claims:Dictionary[ClaimableCellGene, ClaimableCellGene.Claim] = {}

func _init(cell_:Cell, config:ProduceCellGeneConfig):
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
		
class State extends GeneState:
	var energy_used:int
	var energy_per_claim:float
	var claims:Array[ClaimableCellGene.Claim]
	
