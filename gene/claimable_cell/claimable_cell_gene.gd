class_name ClaimableCellGene extends Gene
	
signal claim_added(claim:Claim)

var _claims:Array[Claim] = []
var _resolve_claims:bool = false

var is_claimable:bool:
	get: return not _resolve_claims
	
func perform_actions(index:HexIndex, world:World, _cell:Cell) -> void:
	if _resolve_claims:
		resolve_claims(index, world)
	
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	if _claims.size() > 0:
		_resolve_claims = true

func add_claim(progenitor:Cell, cell_type:CellType) -> void:
	var claim = Claim.new(progenitor, cell_type)
	_claims.append(claim)
	claim_added.emit(claim)
	
func resolve_claims(index:HexIndex, world:World):
	# TODO
	var claim:Claim = _claims[0]
	var new_cell = claim.cell_type.create_cell(claim.progenitor)
	world.set_cell(index, new_cell)

class Claim:
	
	var progenitor:Cell
	var cell_type:CellType
	
	func _init(progenitor_:Cell, cell_type_:CellType):
		progenitor = progenitor_
		cell_type = cell_type_

class ClaimableCellGeneConfig extends GeneConfig:
		
	func create_gene(_progenitor:Cell) -> ClaimableCellGene:
		return ClaimableCellGene.new()
		
class ClaimableCellGeneType extends GeneType:
	
	func _init():
		name = 'ClaimableCell'
		hidden = true
		energy_cost = 1

	func create_config(_cell_type:CellType) -> GeneConfig:
		return ClaimableCellGeneConfig.new(self)
			
static var gene_type_ = ClaimableCellGeneType.new()
