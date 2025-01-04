class_name ClaimableCellGene extends Gene

static func _static_init():
	name = 'ClaimableCell'
			
static func create_gene(_progenitor:Cell, _config:GeneConfig) -> ClaimableCellGene:
	return ClaimableCellGene.new()
	
var _claims:Array[Claim] = []

func perform_actions(index:HexIndex, world:World, _cell:Cell) -> void:
	if _claims.size() > 0:
		resolve_claims(index, world)
	
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass

func add_claim(progenitor:Cell, cell_type:CellType) -> void:
	_claims.append(Claim.new(progenitor, cell_type))
	
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
