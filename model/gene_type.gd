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
			_load_gene_types_from_directory(sub_dir)			
	return _gene_types
	
static func _load_gene_types_from_directory(dir:String) -> void:
	var files = DirAccess.get_files_at(dir)
	for file:String in files:
		if file.ends_with("_gene.gd"):
			var gene_script:Script = load(file)
			var gene_type:GeneType = gene_script.gene_type
			_gene_types.append(gene_type)
