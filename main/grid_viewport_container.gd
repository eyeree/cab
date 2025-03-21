class_name GridViewportContainer extends SubViewportContainer

@onready var _hex_grid: HexGrid = %HexGrid

const CELL_APPEARANCE_CONTAINER = preload("res://main/genomes_panel/cell_appearance_container.tscn")

var _current_drag_data:CellTypeDragData = null

var drag_enabled := false

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	
	if data is not CellTypeDragData:
		return false
		
	if data.source_index != null:
		return true
	else:
		return _hex_grid.mouse_hex_index != HexIndex.INVALID
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	
	if data is not CellTypeDragData:
		return
	
	if _hex_grid.mouse_hex_index != HexIndex.INVALID:
		var initial_hex_content := LevelHexContent.new()
		initial_hex_content.cell_type = data.cell_type
		initial_hex_content.orientation = data.orientation
		Level.current.set_hex_content(_hex_grid.mouse_hex_index, data.cell_type, data.orientation)
		
	Level.current.modified()
	
func _get_drag_data(_at_position: Vector2) -> Variant:
	
	if not drag_enabled:
		return null
	
	var initial_hex_content := Level.current.get_hex_content(_hex_grid.mouse_hex_index)
	
	var cell_appearance_container:CellAppearanceContainer = CELL_APPEARANCE_CONTAINER.instantiate()
	cell_appearance_container.cell_appearance = initial_hex_content.cell_type.instantiate_cell_appearance()
	set_drag_preview(cell_appearance_container)
	
	var data := CellTypeDragData.new()
	data.cell_type = initial_hex_content.cell_type
	data.orientation = initial_hex_content.orientation
	
	if not Input.is_key_pressed(KEY_CTRL):
		data.source_index = _hex_grid.mouse_hex_index
		Level.current.content.clear_content(_hex_grid.mouse_hex_index)
		Level.current.modified()
	
	_current_drag_data = data
	return data

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_END:
			if not is_drag_successful() and _current_drag_data and _current_drag_data.source_index != null:
				Level.current.set_hex_content(_hex_grid.mouse_hex_index, _current_drag_data.cell_type, _current_drag_data.orientation)
				Level.current.modified()
			_current_drag_data = null
