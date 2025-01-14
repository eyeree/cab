extends CellAppearance

@onready var _base: CSGCylinder3D = %Base
@onready var _1_of_1: Node3D = %"1_of_1"
@onready var _1_of_2: Node3D = %"1_of_2"
@onready var _2_of_2: Node3D = %"2_of_2"
@onready var _1_of_3: Node3D = %"1_of_3"
@onready var _2_of_3: Node3D = %"2_of_3"
@onready var _3_of_3: Node3D = %"3_of_3"

var _claim_cell_appearances:Array[CellAppearance] = []

func _ready() -> void:
	_base.visible = false
	_1_of_1.visible = false
	_1_of_2.visible = false
	_2_of_2.visible = false
	_1_of_3.visible = false
	_2_of_3.visible = false
	_3_of_3.visible = false
	
func set_state(state:Dictionary) -> void:
	
	for claim_cell_appearance in _claim_cell_appearances:
		var parent = claim_cell_appearance.get_parent()
		if parent: parent.remove_child(claim_cell_appearance)
		claim_cell_appearance.queue_free()
	_claim_cell_appearances.clear()
	
	var claims:Array = state.get('claims', [])
	if not claims or claims.size() == 0:
		return
		
	_claim_cell_appearances.assign(
		claims.map(func (claim): 
			return claim.cell_type.cell_appearance.instantiate()))
		
	match _claim_cell_appearances.size():
		1:
			_1_of_1.visible = true
			_1_of_1.add_child(_claim_cell_appearances[0])
		2:
			_1_of_2.visible = true
			_2_of_2.visible = true
			_1_of_2.add_child(_claim_cell_appearances[0])
			_2_of_2.add_child(_claim_cell_appearances[1])
		3, _:
			_1_of_3.visible = true
			_2_of_3.visible = true
			_3_of_3.visible = true
			_1_of_3.add_child(_claim_cell_appearances[0])
			_2_of_3.add_child(_claim_cell_appearances[1])
			_3_of_3.add_child(_claim_cell_appearances[2])
			
	_base.visible = true
