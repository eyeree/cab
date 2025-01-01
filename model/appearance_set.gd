class_name AppearanceSet extends Resource

static func _static_init():
	SerializationUtil.register(AppearanceSet) \
		.use_resource_path_for(AppearanceSet)

static var default:AppearanceSet:
	get:
		return load("res://appearance/simple_a/simple_a_appearance_set.tres")

static func get_all_appearance_sets() -> Array[AppearanceSet]:
	var result:Array[AppearanceSet] = []
	var sub_dirs = DirAccess.get_directories_at("res://appearance")
	for sub_dir:String in sub_dirs:
		var files = DirAccess.get_files_at(sub_dir)
		for file:String in files:
			if file.ends_with("_appearance_set.tres"):
				result.append(load(file))
	return result
	
@export var hidden:bool = false

var _base_name:String:
	get:
		return resource_path.get_basename().replace('_appearance_set', '')
		
var _base_dir:String:
	get:
		return resource_path.get_base_dir()
	
var thumbnail:Texture2D:
	get:
		return load(_base_name + '_thumbnail.png')
		
var _cell_appearances:Array[CellAppearance] = []
var cell_appearances:Array[CellAppearance]:
	get:
		if _cell_appearances.size() == 0:
			var files = DirAccess.get_files_at(_base_dir)
			var cell_base_name = _base_name + '_cell_'
			for file in files:
				if file.start_with(cell_base_name):
					var packed_scene:PackedScene = load(file)
					var cell_appearance:CellAppearance = packed_scene.instanciate()
					_cell_appearances.append(cell_appearance)
		return _cell_appearances
	
func get_default_cell_appearance() -> CellAppearance:
	return cell_appearances[0]
	
func has_cell_appearance(cell_appearance:CellAppearance) -> bool:
	return cell_appearances.any(func (entry): return cell_appearance.resource_path == entry)

func get_cell_appearance_by_name(name:String) -> CellAppearance:
	for cell_appearance:CellAppearance in cell_appearances:
		if cell_appearance.name == name:
			return cell_appearance
	push_error('No cell appearance named %s was found in appearance set %s' % [name, resource_path])
	return null
