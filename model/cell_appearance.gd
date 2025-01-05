class_name CellAppearance extends Node3D

func attach(_cell:Cell) -> void:
	pass
	
func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
