class_name CellAppearanceContainer extends SubViewportContainer

@onready var _cell_appearance_holder: Node3D = %CellAppearanceHolder

var cell_type:CellType:
	set(value):
		cell_type = value
		if is_inside_tree():
			_set_cell_appearance()

func _ready() -> void:
	if cell_type:
		_set_cell_appearance()
				
func _set_cell_appearance() -> void:
	var cell_appearance:CellAppearance = cell_type.instantiate_cell_appearance()
	for child in _cell_appearance_holder.get_children():
		_cell_appearance_holder.remove_child(child)
		child.queue_free()
	_cell_appearance_holder.add_child(cell_appearance)
