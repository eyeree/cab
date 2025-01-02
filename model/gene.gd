class_name Gene extends RefCounted

const BASE_PATH = "res://gene/"

static var _genes:Array[Gene] = []

static func get_all_genes() -> Array[Gene]:
	if _genes.size() == 0:
		_load_genes_from_directory(BASE_PATH)
		var sub_dirs = DirAccess.get_directories_at(BASE_PATH)
		for sub_dir:String in sub_dirs:
			_load_genes_from_directory(sub_dir)			
	return _genes
	
static func _load_genes_from_directory(dir:String) -> void:
	var files = DirAccess.get_files_at(dir)
	for file:String in files:
		if file.ends_with("_gene.gd"):
			_genes.append(load(file).new())
			
static func _get_gene_by_name(name:String) -> Gene:
	for gene in get_all_genes():
		if gene.name == name:
			return gene
	return null
	
var name:String = "(new gene)"
var hidden:bool = false
var required_effects:Array[StringName] = []

func create_state(progenitor:Cell, config:GeneConfig) -> GeneState:
	return GeneState.new(self)
	
func create_config(cell_type_:CellType) -> GeneConfig:
	return GeneConfig.new()
