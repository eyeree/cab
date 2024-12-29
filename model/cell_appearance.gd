class_name CellAppearance extends Node3D

@export_file("*.tscn") var supported_effects:Array[String] = []

var resource_path:String:
	get: return scene_file_path
	
func serialize() -> Variant:
	return resource_path
	
static func deserialize(data:Variant) -> CellAppearance:
	return load(data).instantiate()
	
func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
