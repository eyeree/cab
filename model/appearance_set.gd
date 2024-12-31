class_name AppearanceSet extends Resource

#region Serialization

static var _serialization = SerializationUtil.register(AppearanceSet)

static func deserialize(data:Dictionary) -> AppearanceSet:
	return load(data['resource_path']).instantiate()
	
func serialize() -> Dictionary:
	return { 'resource_path': resource_path	}

#endregion	
	
@export_file("*.tscn") var cell_appearances:Array[String] = []
	
func has_cell_appearance(cell_appearance:CellAppearance) -> bool:
	return cell_appearances.any(func (entry): return cell_appearance.resource_path == entry)
