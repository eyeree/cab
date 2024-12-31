class_name CellAppearance extends Node3D

@export_file("*.tscn") var supported_effects:Array[String] = []

var resource_path:String:
	get: return scene_file_path
	
func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)

#region Serialization

static var _serialization = SerializationUtil.register(CellAppearance) \
	.as_resource_path(CellAppearance)

#endregion	
