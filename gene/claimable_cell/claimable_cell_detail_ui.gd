class_name ClaimableCellGeneDetailUI extends GeneDetailUI

class Signals:
	signal highlight_claim(claim:ClaimableCellGene.Claim)

static var claimable_cell_gene_signals := Signals.new()
	
@onready var claim_grid_container: TemplateGridContaier = %ClaimGridContainer
@onready var ranking_data_grid: TemplateGridContaier = %RankingDataGrid
@onready var ranking_data_panel: VBoxContainer = %RankingDataPanel

var current_claim_states:Array[ClaimableCellGene.ClaimState] = []

func _ready() -> void:
	claim_grid_container.mouse_entered_row.connect(_on_mouse_entered_row)
	claim_grid_container.mouse_exited_row.connect(_on_mouse_exited_row)

func show_gene_state(cell_state:CellState) -> void:
	var gene_state:ClaimableCellGene.State = cell_state.get_substate(ClaimableCellGene.State)
	if gene_state == null || gene_state.claim_states.size() == 0:
		visible = false
	else:
		visible = true
		current_claim_states = gene_state.claim_states
		claim_grid_container.clear()
		for claim_state:ClaimableCellGene.ClaimState in gene_state.claim_states:
			
			var row:Array = claim_grid_container.add_row()
			var direction:Label = row[0]
			var cell_type:Label = row[1]
			var energy_cost_container:HBoxContainer = row[2]
			var energy_provided_container:HBoxContainer = row[3]
			var status:Label = row[4]

			var energy_cost:Label = energy_cost_container.get_child(0)
			var energy_provided:Label = energy_provided_container.get_child(0)
			
			direction.text = HexIndex.DIRECTION_LABEL[
				cell_state.cell.index.neighbor_direction(claim_state.progenitor.index)
			]
			
			cell_type.text = claim_state.cell_type.name
			
			energy_cost.text = "-%d" % [claim_state.cell_type.energy_cost]
			energy_provided.text = "%d" % [claim_state.energy_provided]
			
			if gene_state.winning_claim_state == claim_state:
				status.text = "Winner"
			elif claim_state.is_complete:
				status.text = "Ready"
			else:
				status.text = ""
				
			ranking_data_panel.visible = false

func _on_mouse_entered_row(row_index:int) -> void:
	var claim_state := current_claim_states[row_index]
	gene_signals.highlight_cell.emit(claim_state.progenitor.index)
	claimable_cell_gene_signals.highlight_claim.emit(claim_state)
	if claim_state.ranking_data.size() > 0:
		ranking_data_grid.clear()
		for key:String in claim_state.ranking_data.keys():
			var value:Variant = claim_state.ranking_data[key]
			var row = ranking_data_grid.add_row()
			var property_name:Label = row[0]
			var property_value:Label = row[1]
			property_name.text = key.capitalize()
			property_value.text = str(value)
		ranking_data_panel.visible = true

func _on_mouse_exited_row(_row_index:int) -> void:
	gene_signals.highlight_cell.emit(HexIndex.INVALID)
	claimable_cell_gene_signals.highlight_claim.emit(null)
	ranking_data_panel.visible = false
