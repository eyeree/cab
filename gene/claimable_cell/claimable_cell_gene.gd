class_name ClaimableCellGene extends Gene

var _claims:Array[Claim] = []
var is_claimable:bool = true
	
func perform_actions() -> void:
	if not is_claimable:
		# TODO
		var claim:Claim = _claims[0]
		var new_cell = claim.cell_type.create_cell(claim.progenitor)
		cell.world.set_cell(cell.index, new_cell)
		add_state(State.new(_claims, claim))
	
func update_state() -> void:
	if _claims.size() > 0:
		is_claimable = false
		add_state(State.new(_claims))

static var num_claims:int = 0

func is_claimed_by_cell(cell_:Cell) -> bool:
	for claim:Claim in _claims:
		if claim.progenitor == cell_:
			return true
	return false
	
func add_claim(progenitor:Cell, cell_type:CellType) -> void:
	num_claims += 1
	var claim = Claim.new(progenitor, cell_type)
	_claims.append(claim)
	
class State extends GeneState:
	var claims:Array[Claim]
	var resolved_claim:Claim
	func _init(claims_:Array[Claim], resolved_claim_:Claim = null):
		claims = claims_
		resolved_claim = resolved_claim_

class Claim:
	
	var progenitor:Cell
	var cell_type:CellType
	
	func _init(progenitor_:Cell, cell_type_:CellType):
		progenitor = progenitor_
		cell_type = cell_type_

class ClaimableCellGeneConfig extends GeneConfig:
		
	func create_gene(cell:Cell, _progenitor:Cell) -> ClaimableCellGene:
		return ClaimableCellGene.new(cell)
		
class ClaimableCellGeneType extends GeneType:
	
	func _init():
		name = 'ClaimableCell'
		hidden = true
		energy_cost = 1

	func create_config(_cell_type:CellType) -> GeneConfig:
		return ClaimableCellGeneConfig.new(self)
			
static var gene_type_ = ClaimableCellGeneType.new()
