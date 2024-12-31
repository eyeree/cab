class_name CellAppearance extends Node3D

static func _static_init():
	SerializationUtil.register(CellAppearance) \
		.use_scene_file_path_for(CellAppearance)
	
@export_file("*.tscn") var supported_effects:Array[String] = []

func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
