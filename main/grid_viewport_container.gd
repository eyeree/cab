class_name GridViewportContainer extends SubViewportContainer

@onready var _hex_grid: HexGrid = %HexGrid

signal cell_type_dropped(index:HexIndex, cell_type:CellType)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is CellType and _hex_grid.mouse_hex_index != HexIndex.INVALID
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is CellType and _hex_grid.mouse_hex_index != HexIndex.INVALID:
		cell_type_dropped.emit(_hex_grid.mouse_hex_index, data)
	
