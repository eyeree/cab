class_name GeneDetailUI extends PanelContainer

class Signals:
	@warning_ignore("unused_signal")
	signal highlight_cell(index:HexIndex)

static var gene_signals := Signals.new()

func show_gene_state(_cell_state:CellState) -> void:
	pass
	
