class_name GeneType extends Resource
	
@export var name:String = '(new gene type)'
@export var energy_cost:int = 0
@export var hidden:bool = false

var base_resource_path:String:
	get: return resource_path.get_basename().replace('_type', '') # TODO regex
	
const BASE_PATH = "res://gene/"

static var _gene_types:Array[GeneType] = []

static func get_all_gene_types() -> Array[GeneType]:
	if _gene_types.size() == 0:
		_load_gene_types_from_directory(BASE_PATH)
		var sub_dirs = DirAccess.get_directories_at(BASE_PATH)
		for sub_dir:String in sub_dirs:
			var sub_dir_path = BASE_PATH.path_join(sub_dir)
			_load_gene_types_from_directory(sub_dir_path)			
	return _gene_types
	
static func _load_gene_types_from_directory(dir_path:String) -> void:
	var files := DirAccess.get_files_at(dir_path)
	for file in files:
		if file.get_basename().ends_with("_gene_type"):
			var file_path = dir_path.path_join(file)
			var gene_type:GeneType = load(file_path)
			_gene_types.append(gene_type)

static func for_gene_class(gene_class:Script) -> GeneType:
	return load(gene_class.resource_path.get_basename() + '_type.tres')
	
var _state_panel_loaded:bool = false
var _state_panel_scene:PackedScene = null

func get_gene_state_panel() -> GeneStatePanel:
	if not _state_panel_loaded:
		var state_panel_resource_path := base_resource_path + '_state_panel.tscn'
		if ResourceLoader.exists(state_panel_resource_path):
			_state_panel_scene = load(state_panel_resource_path)
		_state_panel_loaded = true
	if _state_panel_scene != null:
		return _state_panel_scene.instantiate()
	else:
		return null

var _config_panel_loaded:bool = false
var _config_panel_scene:PackedScene = null

func get_gene_config_panel() -> GeneConfigPanel:
	if not _config_panel_loaded:
		var config_panel_resource_path := base_resource_path + '_config_panel.tscn'
		if ResourceLoader.exists(config_panel_resource_path):
			_config_panel_scene = load(config_panel_resource_path)
		_config_panel_loaded = true
	if _config_panel_scene != null:
		return _config_panel_scene.instantiate()
	else:
		return null
		
func get_edge_attribute_list() -> Array[CellType.EdgeAttributeInfo]:
	return []

func get_cell_attribute_list() -> Array[CellType.CellAttributeInfo]:
	return []
	
func _to_string() -> String:
	return "GeneType:%s" % [name]

var _config_class:Script = null
func create_config() -> GeneConfig:
	if _config_class == null:
		_config_class = load(base_resource_path + '_config.gd')
		assert(_config_class, 'gene type %s did not define config class' % [resource_path])
	return _config_class.new()
