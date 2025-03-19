extends CellAppearance

@onready var start_mesh: MeshInstance3D = %Start
@onready var end_mesh: MeshInstance3D = %End
@onready var highlight: MeshInstance3D = %Highlight
@onready var current_mesh: MeshInstance3D = %Current

var _claim_cell_appearances:Array[CellAppearance] = []
var _claim_states:Array[ClaimableCellGene.ClaimState] = []

#var _highlighted_cell_appearance:CellAppearance = null
#
#func _ready() -> void:
	#ClaimableCellGeneViewPanel.claimable_cell_gene_signals.highlight_claim.connect(_highlight_claim)
	#
#func _highlight_claim(claim:ClaimableCellGene.Claim) -> void:
	#
	#if claim == null or not _claim_states.has(claim):
		#start_mesh.visible = false
		#end_mesh.visible = false
		#current_mesh.visible = false
		#highlight.visible = false
		#highlight.reparent(self, false)
		#return
	#
	#var grid:HexGrid = get_grid()
	#if grid == null: 
		#return
		#
	#var start:Vector3 = grid.get_center_point(claim.progenitor.index)
	#var end:Vector3 = grid.get_center_point(index)
	#start += (end - start) * 0.3
	#
	##start_mesh.global_position = start # + Vector3(0.0, 0.2, 0.0)
	#start_mesh.position = to_local(start)
	#start_mesh.visible = true
	#
	##end_mesh.global_position = end # + Vector3(0.0, 0.2, 0.0)
	#end_mesh.position = to_local(end)
	#end_mesh.visible = true
	#
	#var percent_complete:float = min(1.0, float(claim.energy_provided) / float(claim.cell_type.get_energy_cost())
	##percent_complete = max(0.0, percent_complete - (0.1 * i))
			#
	#var appearance_position:Vector3 = start + ((end - start) * percent_complete)
	#current_mesh.position = to_local(appearance_position)
	#current_mesh.visible = true
#
	#var i = _claim_states.find(claim)
	#_highlighted_cell_appearance = _claim_cell_appearances[i]
	#highlight.reparent(_highlighted_cell_appearance, false)
	#highlight.visible = true

	
func set_state(cell_state:CellState) -> void:
	
	for claim_cell_appearance in _claim_cell_appearances:
		var parent = claim_cell_appearance.get_parent()
		if parent: 
			parent.remove_child(claim_cell_appearance)
		claim_cell_appearance.visible = false
		claim_cell_appearance.queue_free()
	_claim_cell_appearances.clear()
	
	var gene_state:ClaimableCellGene.State = cell_state.get_substate(ClaimableCellGene.State)
	if gene_state == null:
		return

	var grid:HexGrid = get_grid()
	if grid == null: 
		return
		
	_claim_states.assign(
		gene_state.claim_states.filter(
			func (claim_state): 
				return claim_state.energy_provided > 0.0))
	_claim_states.sort_custom(ClaimableCellGene.rank_claims)
	_claim_cell_appearances.assign(
		_claim_states.map(func (claim): 
			return claim.cell_type.instantiate_cell_appearance()))
			
	for i:int in range(_claim_cell_appearances.size()):
		
		var cell_appearance:CellAppearance = _claim_cell_appearances[i]
		var claim_state:ClaimableCellGene.ClaimState = _claim_states[i]

		var percent_complete:float = min(1.0, float(claim_state.energy_provided) / float(claim_state.cell_type.get_energy_cost()))
		percent_complete = max(0.0, percent_complete - (0.1 * i))
		
		var start:Vector3 = grid.get_center_point(claim_state.progenitor.index)
		var end:Vector3 = grid.get_center_point(cell_state.cell.index)
		start += (end - start) * 0.3	
	
		var appearance_position:Vector3 = start + ((end - start) * percent_complete)
		cell_appearance.position = to_local(appearance_position)
		
		var appearance_scale:float = 0.2 + (0.7 * percent_complete)
		cell_appearance.scale = Vector3(appearance_scale, appearance_scale, appearance_scale)
		cell_appearance.visible = false
		add_child(cell_appearance)
		cell_appearance.set_visible.call_deferred(true)
