class_name ClaimableCellGene extends Gene

var _claims:Array[Claim] = []
var is_claimable:bool = true
	
func perform_actions(index:HexIndex, world:World, _cell:Cell, cell_history:Dictionary) -> void:
	if not is_claimable:
		resolve_claims(index, world, cell_history)
	
func update_state(_index:HexIndex, _world:World, _cell:Cell, cell_history:Dictionary) -> void:
	if _claims.size() > 0:
		is_claimable = false
		cell_history['claims'] = _claims

static var num_claims:int = 0

func add_claim(progenitor:Cell, cell_type:CellType) -> void:
	num_claims += 1
	var claim = Claim.new(progenitor, cell_type)
	_claims.append(claim)
	
func resolve_claims(index:HexIndex, world:World, cell_history:Dictionary):
	# TODO
	var claim:Claim = _claims[0]
	var new_cell = claim.cell_type.create_cell(claim.progenitor)
	world.set_cell(index, new_cell)
	cell_history['resolved_claim'] = true

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
