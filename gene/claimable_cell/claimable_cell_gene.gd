class_name ClaimableCellGene extends Gene

var claims:Array[Claim] = []
var winning_claim:Claim = null

var is_claimable:bool:
	get: return winning_claim == null
	
func perform_actions() -> void:
	if winning_claim != null:
		var new_cell = winning_claim.cell_type.create_cell(winning_claim.progenitor, cell.state)
		cell.world.set_cell(cell.index, new_cell)
	
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
	add_state(State.new(claims, winning_claim))
	claims = []
	
static func rank_claims(a:Claim, b:Claim) -> bool:
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
					a.ranking_data['genome_rank'] = a.world.get_genome_rank(a.progenitor.genome)
					b.ranking_data['genome_rank'] = b.world.get_genome_rank(b.progenitor.genome)
					if a.ranking_data['genome_rank'] < b.ranking_data['genome_rank']:
						return true
	return false

func add_claim(progenitor:Cell, cell_type:CellType, energy_provided:int) -> void:
	var claim:Claim = Claim.new(progenitor, cell_type, energy_provided)
	claims.append(claim)
	
class State extends GeneState:
	var claims:Array[Claim]
	var winning_claim:Claim
	func _init(claims_:Array[Claim], winning_claim_:Claim = null):
		claims = claims_
		winning_claim = winning_claim_

class Claim:
	
	var progenitor:Cell
	var cell_type:CellType
	var energy_provided:int
	var ranking_data:Dictionary[String, Variant] = {}
	
	func _init(progenitor_:Cell, cell_type_:CellType, energy_provided_:int):
		progenitor = progenitor_
		cell_type = cell_type_
		energy_provided = energy_provided_
		
	var is_complete:bool:
		get: return energy_provided >= cell_type.energy_cost

class ClaimableCellGeneConfig extends GeneConfig:
		
	func create_gene(cell:Cell, _progenitor:Cell) -> ClaimableCellGene:
		return ClaimableCellGene.new(cell)
		
class ClaimableCellGeneType extends GeneType:
	
	func _init():
		name = 'ClaimableCell'
		hidden = true
		energy_cost = 1

	func create_config() -> GeneConfig:
		return ClaimableCellGeneConfig.new(self)
			
static var gene_type_ = ClaimableCellGeneType.new()
