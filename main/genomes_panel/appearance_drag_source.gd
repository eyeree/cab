class_name AppearanceDragSource extends Panel

const CELL_APPEARANCE_CONTAINER = preload("res://main/genomes_panel/cell_appearance_container.tscn")

var cell_type:CellType

func _get_drag_data(_at_position: Vector2) -> Variant:
	var cell_appearance_container:CellAppearanceContainer = CELL_APPEARANCE_CONTAINER.instantiate()
	cell_appearance_container.cell_type = cell_type
	set_drag_preview(cell_appearance_container)
	return cell_type
