class_name AppearanceSet extends Resource

static var _serialization = SerializationUtil.register(AppearanceSet) \
	.as_resource_path(AppearanceSet)

@export_file("*.tscn") var cell_appearances:Array[String] = []
	
func has_cell_appearance(cell_appearance:CellAppearance) -> bool:
	return cell_appearances.any(func (entry): return cell_appearance.resource_path == entry)
