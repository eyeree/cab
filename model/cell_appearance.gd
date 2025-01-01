class_name CellAppearance extends Node3D

@export_file("*.tscn") var supported_effects:Array[String] = []

func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
