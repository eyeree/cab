class_name GeneType extends RefCounted
	
var name:String = '(new gene type)'
var energy_cost:int = 0
var hidden:bool = false
	
func create_config(_cell_type:CellType) -> GeneConfig:
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
				_gene_types.append(gene_type)

var _detail_ui:PackedScene = null

const default_detail_ui_resource_path = "res://gene/default/default_detail_ui.tscn"

func get_detail_ui() -> Control:
	if _detail_ui == null:
		var gene_resource_path:String = get_script().resource_path
		var detail_ui_resource_path:String = gene_resource_path.replace('_gene.gd', '_detail_ui.tscn')
		if ResourceLoader.exists(detail_ui_resource_path):
			_detail_ui = load(detail_ui_resource_path)
		else:
			_detail_ui = load(default_detail_ui_resource_path)
	var scene = _detail_ui.instantiate()
	return scene
