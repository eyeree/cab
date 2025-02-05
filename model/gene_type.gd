class_name GeneType extends RefCounted
	
var name:String = '(new gene type)'
var energy_cost:int = 0
var hidden:bool = false
var base_resource_path:String = ''
	
func create_config() -> GeneConfig:
	push_error('Gene type %s did not noverride create_config' % [name])
	return null

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
	var files = DirAccess.get_files_at(dir_path)
	for file:String in files:
		file = file.replace('.remap', '')
		if file.ends_with("_gene.gd"):
			var file_path = dir_path.path_join(file)
			var gene_script:Script = load(file_path)
			var gene_type:GeneType = gene_script.get('gene_type_')
			if gene_type == null:
				push_error("Gene %s did not define gene_type_" % [file_path])
			else:
				gene_type.base_resource_path = file_path.replace('_gene.gd', '')
				_gene_types.append(gene_type)

var _detail_ui_loaded:bool = false
var _detail_ui_scene:PackedScene = null

func get_details_ui() -> GeneDetailUI:
	if not _detail_ui_loaded:
		var detail_ui_resource_path:String = base_resource_path + '_detail_ui.tscn'
		detail_ui_resource_path = detail_ui_resource_path.replace('.remap', '')
		if ResourceLoader.exists(detail_ui_resource_path):
			_detail_ui_scene = load(detail_ui_resource_path)
		_detail_ui_loaded = true
	if _detail_ui_scene != null:
		return _detail_ui_scene.instantiate()
	else:
		return null

func get_edge_attribute_names() -> Array[StringName]:
	return []

func get_cell_attribute_names() -> Array[StringName]:
	return []
	
func _to_string() -> String:
	return "GeneType:%s" % [name]
