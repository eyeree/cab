extends CellAppearance

@onready var start_mesh: MeshInstance3D = %Start
@onready var end_mesh: MeshInstance3D = %End

var _claim_cell_appearances:Array[CellAppearance] = []
	
func set_state(cell_state:CellState) -> void:
	
	for claim_cell_appearance in _claim_cell_appearances:
		var parent = claim_cell_appearance.get_parent()
		if parent: parent.remove_child(claim_cell_appearance)
		claim_cell_appearance.queue_free()
	_claim_cell_appearances.clear()
	
	var claim_state:ClaimableCellGene.State = cell_state.get_substate(ClaimableCellGene.State)
	if claim_state == null or claim_state.claims.size() == 0:
		return

	var grid:Grid = get_grid()
	if grid == null: 
		return
		
	var claims:Array[ClaimableCellGene.Claim] = []
	claims.assign(claim_state.claims)
	claims.sort_custom(ClaimableCellGene.rank_claims)
	_claim_cell_appearances.assign(
		claims.map(func (claim): 
			return claim.cell_type.cell_appearance.instantiate()))
			
	for i:int in range(_claim_cell_appearances.size()):

		var cell_appearance:CellAppearance = _claim_cell_appearances[i]
		var claim:ClaimableCellGene.Claim = claim_state.claims[i]

		var percent_complete:float = min(1.0, float(claim.energy_provided) / float(claim.cell_type.energy_cost))
		#percent_complete = max(0.0, percent_complete - (0.1 * i))
		
		var start:Vector3 = grid.get_center_point(claim.progenitor.index)
		var end:Vector3 = grid.get_center_point(index)
		start += (end - start) * 0.3
		
		start_mesh.global_position = start + Vector3(0.0, 0.2, 0.0)
		end_mesh.global_position = end + Vector3(0.0, 0.2, 0.0)
		
		var appearance_position:Vector3 = start + ((end - start) * percent_complete)
		cell_appearance.position = to_local(appearance_position)
		
		var appearance_scale = 0.2 + (0.7 * percent_complete)
		cell_appearance.scale = Vector3(appearance_scale, appearance_scale, appearance_scale)
		
		add_child(cell_appearance)
		
	#match _claim_cell_appearances.size():
		#1:
			#_1_of_1.visible = true
			#_1_of_1.add_child(_claim_cell_appearances[0])
		#2:
			#_1_of_2.visible = true
			#_2_of_2.visible = true
			#_1_of_2.add_child(_claim_cell_appearances[0])
			#_2_of_2.add_child(_claim_cell_appearances[1])
		#3, _:
			#_1_of_3.visible = true
			#_2_of_3.visible = true
			#_3_of_3.visible = true
			#_1_of_3.add_child(_claim_cell_appearances[0])
			#_2_of_3.add_child(_claim_cell_appearances[1])
			#_3_of_3.add_child(_claim_cell_appearances[2])
			#
	#_base.visible = true
