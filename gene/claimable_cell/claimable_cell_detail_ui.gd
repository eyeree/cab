class_name ClaimableCellGeneDetailUI extends GeneDetailUI

@onready var claim_grid_container: TemplateGridContaier = %ClaimGridContainer

var current_claims:Array[ClaimableCellGene.Claim] = []

func _ready() -> void:
	claim_grid_container.mouse_entered_row.connect(_on_mouse_entered_row)
	claim_grid_container.mouse_exited_row.connect(_on_mouse_exited_row)

func show_gene_state(cell_state:CellState) -> void:
	var gene_state:ClaimableCellGene.State = cell_state.get_substate(ClaimableCellGene.State)
	if gene_state == null || gene_state.claims.size() == 0:
		visible = false
	else:
		visible = true
		current_claims = gene_state.claims
		claim_grid_container.clear()
		for claim:ClaimableCellGene.Claim in gene_state.claims:
			
			var row:Array = claim_grid_container.add_row()
			var direction:Label = row[0]
			var cell_type:Label = row[1]
			var energy_cost_container:HBoxContainer = row[2]
			var energy_cost:Label = energy_cost_container.get_child(0)
			
			direction.text = HexIndex.DIRECTION_LABEL[
				cell_state.cell.index.direction_to(claim.progenitor.index)
			]
			
			cell_type.text = claim.cell_type.name
			energy_cost.text = "-%d" % [claim.cell_type.energy_cost]

func _on_mouse_entered_row(row_index:int) -> void:
	var claim:ClaimableCellGene.Claim = current_claims[row_index]
	highlight_cell(claim.progenitor.index)

func _on_mouse_exited_row(_row_index:int) -> void:
	highlight_cell(HexIndex.INVALID)
