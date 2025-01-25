class_name ClaimableCellGeneDetailUI extends GeneDetailUI

@onready var claim_grid_container: TemplateGridContaier = %ClaimGridContainer
@onready var ranking_data_grid: TemplateGridContaier = %RankingDataGrid
@onready var ranking_data_panel: VBoxContainer = %RankingDataPanel

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
			var energy_provided_container:HBoxContainer = row[3]
			var status:Label = row[4]

			var energy_cost:Label = energy_cost_container.get_child(0)
			var energy_provided:Label = energy_provided_container.get_child(0)
			
			direction.text = HexIndex.DIRECTION_LABEL[
				cell_state.cell.index.direction_to(claim.progenitor.index)
			]
			
			cell_type.text = claim.cell_type.name
			
			energy_cost.text = "-%d" % [claim.cell_type.energy_cost]
			energy_provided.text = "%d" % [claim.energy_provided]
			
			if gene_state.winning_claim == claim:
				status.text = "Winner"
			elif claim.is_complete:
				status.text = "Ready"
			else:
				status.text = ""
				
			ranking_data_panel.visible = false

func _on_mouse_entered_row(row_index:int) -> void:
	var claim:ClaimableCellGene.Claim = current_claims[row_index]
	highlight_cell(claim.progenitor.index)
	if claim.ranking_data.size() > 0:
		ranking_data_grid.clear()
		for key:String in claim.ranking_data.keys():
			var value:Variant = claim.ranking_data[key]
			var row = ranking_data_grid.add_row()
			var property_name:Label = row[0]
			var property_value:Label = row[1]
			property_name.text = key.capitalize()
			property_value.text = str(value)
		ranking_data_panel.visible = true

func _on_mouse_exited_row(_row_index:int) -> void:
	highlight_cell(HexIndex.INVALID)
	ranking_data_panel.visible = false
