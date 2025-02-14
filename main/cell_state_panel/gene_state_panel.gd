class_name GeneStatePanel extends PanelContainer

enum TargetType { Good, Netural, Bad }

class Signals:
	@warning_ignore("unused_signal")
	signal set_target_highlight(index:HexIndex, type:TargetType)
	
	@warning_ignore("unused_signal")
	signal clear_target_highlight(index:HexIndex)

static var gene_signals := Signals.new()

func show_gene_state(_cell_state:CellState) -> void:
	pass
	
