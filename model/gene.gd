class_name Gene extends RefCounted

const BASE_PATH = "res://gene/"

static var _gene_types:Array[Script] = []

static func get_all_gene_types() -> Array[Script]:
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
			_gene_types.append(load(file))
			
static var name:String = '(new gene)'
static var hidden:bool = false
static var required_effects:Array[StringName] = []
static var energy_cost:int = 0

static func _is_not_config_type(config:GeneConfig, type:Script) -> bool:
	if not is_instance_of(config, type):
		push_error('Wrong config type passed to gene %s create_gene: %s' % [name, config])
		return false
	else:
		return true
		
static func create_gene(_progenitor:Cell, _config:GeneConfig) -> Gene:
	return Gene.new()
	
static func create_config(_cell_type:CellType) -> GeneConfig:
	return GeneConfig.new(Gene)

func perform_actions(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass

func damage_resistance(_damange_amount:float, _damange_type:Cell.DamageType) -> float:
	return 0
