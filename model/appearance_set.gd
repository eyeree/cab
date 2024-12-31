class_name AppearanceSet extends Resource

static func _static_init():
	SerializationUtil.register(AppearanceSet) \
		.use_resource_path_for(AppearanceSet)

@export_file("*.tscn") var cell_appearances:Array[String] = []
	
func has_cell_appearance(cell_appearance:CellAppearance) -> bool:
	return cell_appearances.any(func (entry): return cell_appearance.resource_path == entry)
