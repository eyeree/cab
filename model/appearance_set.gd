class_name AppearanceSet extends Resource

static var default:AppearanceSet:
	get:
		return load("res://appearance/simple_a/simple_a_appearance_set.tres")

static func get_all_appearance_sets() -> Array[AppearanceSet]:
	var result:Array[AppearanceSet] = []
	var base_dir:String = "res://appearance"
	var sub_dirs = DirAccess.get_directories_at(base_dir)
	for sub_dir:String in sub_dirs:
		var sub_dir_path := base_dir.path_join(sub_dir)
		var files = DirAccess.get_files_at(sub_dir_path)
		for file:String in files:
			file = file.replace('.remap', '')
			if file.ends_with("_appearance_set.tres"):
				var file_path := sub_dir_path.path_join(file)
				result.append(load(file_path))
	return result
	
static func get_appearance_set(name:String) -> AppearanceSet:
	for appearance_set in get_all_appearance_sets():
		if appearance_set.name == name:
			return appearance_set
	return null
	
@export var name:String = ''
@export var hidden:bool = false

var _base_name:String:
	get:
		return resource_path.get_basename().get_file().replace('_appearance_set', '')
		
var _base_dir:String:
	get:
		return resource_path.get_base_dir()
	
var thumbnail:Texture2D:
	get:
		return load(_base_name + '_thumbnail.png')
		
var _cell_appearances:Array[PackedScene] = []
var cell_appearances:Array[PackedScene]:
	get:
		if _cell_appearances.size() == 0:
			var cell_base_name = _base_name + '_cell_'
			_add_cell_appearances_from_dir(_base_dir, cell_base_name)
			for sub_dir in DirAccess.get_directories_at(_base_dir):
				_add_cell_appearances_from_dir(_base_dir.path_join(sub_dir), cell_base_name)
		return _cell_appearances

func _add_cell_appearances_from_dir(dir:String, cell_base_name:String) -> void:
	var files = DirAccess.get_files_at(dir)
	for file:String in files:
		file = file.replace('.remap', '')
		if file.begins_with(cell_base_name) and file.ends_with('.tscn'):
			var packed_scene:PackedScene = load(dir.path_join(file))
			_cell_appearances.append(packed_scene)
	
func get_default_cell_appearance() -> PackedScene:
	return cell_appearances[0]
	
func has_cell_appearance(cell_appearance:PackedScene) -> bool:
	return cell_appearances.any(func (entry): return cell_appearance.resource_path == entry.resource_path)

func get_cell_appearance_index_by_name(name:String) -> int:
	var index := cell_appearances.find_custom(
		func (cell_appearance:PackedScene): 
			return cell_appearance.resource_path.get_file().get_basename() == name)
	if index == -1:
		push_error('No cell appearance named %s was found in appearance set %s' % [name, resource_path])
	return index
