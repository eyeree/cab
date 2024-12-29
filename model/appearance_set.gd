class_name AppearanceSet extends Resource

static func deserialize(data:Variant) -> AppearanceSet:
	return load(data).instantiate()
	
func serialize() -> Variant:
	return resource_path
	
@export_file("*.tscn") var cell_appearances:Array[String] = []
	
func has_cell_appearance(cell_appearance:CellAppearance) -> bool:
	return cell_appearances.any(func (entry): return cell_appearance.resource_path == entry)
