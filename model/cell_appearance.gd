class_name CellAppearance extends Node3D

func set_state(_cell_history:CellState) -> void:
	pass
	
func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
