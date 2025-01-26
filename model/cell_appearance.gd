class_name CellAppearance extends Node3D

func set_state(_cell_history:CellState) -> void:
	pass
	
func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)

func get_grid() -> Grid:
	var parent:Node3D = get_parent_node_3d()
	while parent != null:
		if parent is Grid:
			return parent
		parent = parent.get_parent_node_3d()
	return null
	
var index:HexIndex = null
