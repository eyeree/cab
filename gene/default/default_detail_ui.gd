extends PanelContainer

@onready var title_label: Label = %TitleLabel

func show_gene(gene:Gene) -> void:
	title_label.text = gene.gene_type.name
