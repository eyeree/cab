class_name GeneDetailUI extends PanelContainer

func show_gene_state(_cell_state:CellState) -> void:
	pass
	
func highlight_cell(index:HexIndex) -> void:
	var parent = get_parent()
	while parent != null && parent is not BattleMode:
		parent = parent.get_parent()
	if parent != null:
		parent.highlight_cell(index)
