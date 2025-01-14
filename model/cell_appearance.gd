class_name CellAppearance extends Node3D

func set_state(state:Dictionary) -> void:
	pass
	
func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
