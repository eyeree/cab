extends Node
@onready var default_detail_ui: DefaultGeneDetailUI = %DefaultDetailUI

func show_gene(gene:ClaimableCellGene) -> void:
	default_detail_ui.show_gene(gene)
