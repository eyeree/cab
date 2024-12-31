class_name CellAppearance extends Node3D

@export_file("*.tscn") var supported_effects:Array[String] = []

static var _serialization = SerializationUtil.register(CellAppearance) \
	.as_scene_file_path(CellAppearance)

func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
