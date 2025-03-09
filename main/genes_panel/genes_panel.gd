class_name GenesPanel extends PanelContainer

@onready var label: Label = %Label

func _ready() -> void:
	pass

func show_cell_type(cell_type:CellType) -> void:
	if cell_type == null:
		label.text = '(no cell type selected)'
	else:
		label.text = str(cell_type)	
