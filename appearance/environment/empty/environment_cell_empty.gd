extends CellAppearance

@onready var _base: CSGCylinder3D = %Base
@onready var _1_of_1: Node3D = %"1_of_1"
@onready var _1_of_2: Node3D = %"1_of_2"
@onready var _2_of_2: Node3D = %"2_of_2"
@onready var _1_of_3: Node3D = %"1_of_3"
@onready var _2_of_3: Node3D = %"2_of_3"
@onready var _3_of_3: Node3D = %"3_of_3"

var _claims:Array[CellAppearance] = []

func _ready() -> void:
	_base.visible = false
	_1_of_1.visible = false
	_1_of_2.visible = false
	_2_of_2.visible = false
	_1_of_3.visible = false
	_2_of_3.visible = false
	_3_of_3.visible = false
	
func attach(cell:Cell) -> void:
	var claimable_cell_gene:ClaimableCellGene = cell.get_gene(ClaimableCellGene)
	claimable_cell_gene.claim_added.connect(_on_claim_added)
	
func _on_claim_added(claim:ClaimableCellGene.Claim) -> void:
	var cell_appearance:CellAppearance = claim.cell_type.cell_appearance.instantiate()
	_claims.append(cell_appearance)
	match _claims.size():
		1:
			_1_of_1.visible = true
			_1_of_1.add_child(cell_appearance)
		2:
			_1_of_1.visible = false
			_1_of_2.visible = true
			_2_of_2.visible = true
			_claims[0].reparent(_1_of_2, false)
			_2_of_2.add_child(cell_appearance)
		3, _:
			_1_of_2.visible = false
			_2_of_2.visible = false
			_1_of_3.visible = true
			_2_of_3.visible = true
			_3_of_3.visible = true
			_claims[0].reparent(_1_of_3, false)
			_claims[1].reparent(_2_of_3, false)
			_3_of_3.add_child(cell_appearance)
	_base.visible = true
