class_name ClaimableCellGene extends Gene

var claims:Array[Claim] = []
var winning_claim:Claim = null

var is_claimable:bool:
	get: return winning_claim == null
	
func perform_actions() -> void:
	if winning_claim != null:
		cell.world.set_cell(cell.index, winning_claim.cell_type, winning_claim.progenitor)
		for claim in claims: 
			if not claim.cancelled:
				claim.completed.emit(claim == winning_claim)			
	
func update_state() -> void:
	var completed_claims:Array[Claim] = []
	completed_claims.assign(
		claims.filter(
			func (claim): 
				return claim.is_complete))
	if completed_claims.size() > 0:
		if completed_claims.size() > 1:
			completed_claims.sort_custom(rank_claims)
		winning_claim = completed_claims[0]
	add_state(State.new(claims.duplicate(), winning_claim))
	
static func rank_claims(a:ClaimState, b:ClaimState) -> bool:
	if a.energy_provided > b.energy_provided:
		return true
	elif a.energy_provided == b.energy_provided:
		a.ranking_data['progenitor_life'] = a.progenitor.life
		b.ranking_data['progenitor_life'] = b.progenitor.life
		if a.progenitor.life > b.progenitor.life:
			return true
		elif a.progenitor.life == b.progenitor.life:
			a.ranking_data['connected_life'] = a.progenitor.connected_life
			b.ranking_data['connected_life'] = b.progenitor.connected_life
			if a.progenitor.connected_life > b.progenitor.connected_life:
				return true
			elif a.progenitor.connected_life == b.progenitor.connected_life:
				if a.progenitor.genome == b.progenitor.genome:
					a.ranking_data['cell_type_rank'] = a.progenitor.genome.get_cell_type_rank(a.progenitor.cell_type)
					b.ranking_data['cell_type_rank'] = b.progenitor.genome.get_cell_type_rank(b.progenitor.cell_type)
					if a.ranking_data['cell_type_rank'] < b.ranking_data['cell_type_rank']:
						return true
					elif a.ranking_data['cell_type_rank'] == b.ranking_data['cell_type_rank']:
						a.ranking_data['cell_number'] = a.progenitor.cell_number
						b.ranking_data['cell_number'] = b.progenitor.cell_number
						if a.progenitor.cell_number < b.progenitor.cell_number:
							return true
				else:					
					a.ranking_data['genome_rank'] = a.progenitor.world.get_genome_rank(a.progenitor.genome)
					b.ranking_data['genome_rank'] = b.progenitor.world.get_genome_rank(b.progenitor.genome)
					if a.ranking_data['genome_rank'] < b.ranking_data['genome_rank']:
						return true
	return false

func add_claim(progenitor:Cell, cell_type:CellType) -> Claim:
	var claim := Claim.new(progenitor, cell_type)		
	var i := claims.find_custom(func (entry:Claim): return entry.progenitor == progenitor)
	if i != -1:
		claims[i] = claim
	else:
		claims.append(claim)
	return claim	
	
class State extends GeneState:
	var claim_states:Array[ClaimState] = []
	var winning_claim_state:ClaimState
	func _init(claims_:Array[Claim], winning_claim_:Claim = null):
		winning_claim_state = winning_claim_.get_claim_state() if winning_claim_ else null
		claim_states.assign(
			claims_.map(
				func (claim:Claim): 
					if claim == winning_claim_:
						return winning_claim_state
					else:
						return claim.get_claim_state()))

class ClaimState:
	
	var cancelled:bool = false
	var progenitor:Cell
	var cell_type:CellType
	var energy_provided:float = 0.0
	var ranking_data:Dictionary[String, Variant] = {}
	
	var is_complete:bool:
		get: return energy_provided >= cell_type.energy_cost and not cancelled

class Claim extends ClaimState:
	
	signal completed(successful:bool)
	
	func _init(progenitor_:Cell, cell_type_:CellType):
		progenitor = progenitor_
		cell_type = cell_type_
		
	func cancel() -> void:
		cancelled = true
		completed.emit(false)
		
	func get_claim_state() -> ClaimState:
		var claim_state := ClaimState.new()
		claim_state.progenitor = progenitor
		claim_state.cell_type = cell_type
		claim_state.energy_provided = energy_provided
		claim_state.ranking_data = ranking_data.duplicate()
		return claim_state
