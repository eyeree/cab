class_name CellType extends Resource

var _genome_ref:WeakRef = null
var genome:Genome:
	get: 
		if _genome_ref == null || _genome_ref.get_ref() == null:
			_genome_ref = weakref(Genome.get_cell_type_genome(self))
			if _genome_ref == null:
				prints('could not find genome')
				return null
		var result = _genome_ref.get_ref()
		if result == null:
			prints('genome ref is null')
			return null
		return result

@export var name:String = '(new cell type)'
@export var gene_configs:Array[GeneConfig] = []
@export var cell_appearance_index:int = 0

var cached_energy_cost := -1;

func get_energy_cost() -> int:
	var total = 0
	for gene_config in gene_configs:
		total += gene_config.get_energy_cost()
	return total

func add_gene_config(gene_config:GeneConfig) -> void:
	gene_configs.append(gene_config)
			
func remove_gene_config(gene_config:GeneConfig) -> void:
	gene_configs.erase(gene_config)
	
func add_gene_type(gene_type:GeneType) -> GeneConfig:
	var gene_config = gene_type.create_config()
	add_gene_config(gene_config)
	return gene_config
	
func remove_gene_type(gene_type:GeneType) -> void:
	gene_configs = gene_configs.filter(
		func (gene_config:GeneConfig): 
			return gene_config.gene_type != gene_type)

func has_gene_type(gene_type:GeneType) -> bool:
	for gene_config in gene_configs:
		if gene_config.gene_type == gene_type:
			return true
	return false

func add_gene(gene_class:Script) -> GeneConfig:
	return add_gene_type(GeneType.for_gene_class(gene_class))	

func has_gene(gene_class:Script) -> bool:
	return has_gene_type(GeneType.for_gene_class(gene_class))
	
class AttributeInfo:
	var name:StringName
	var description:String
	var type:Variant.Type
	
	func _init(name_:StringName, type_:Variant.Type, description_:String) -> void:
		name = name_
		description = description_
		type = type_
	
class EdgeAttributeInfo extends AttributeInfo:
	pass
	
class CellAttributeInfo extends AttributeInfo:
	pass
	
func get_edge_attribute_list() -> Array[EdgeAttributeInfo]:
	var names:Array[EdgeAttributeInfo] = []
	for gene_config:GeneConfig in gene_configs:
		names.append_array(gene_config.gene_type.get_edge_attribute_list())
	return names
		
func get_cell_attribute_list() -> Array[CellAttributeInfo]:
	var names:Array[CellAttributeInfo] = [
		CellAttributeInfo.new("life_percent", TYPE_FLOAT,
			"Cell's current life as a percentage of it's maximum life. Range: 0.0 to 1.0"), 
		CellAttributeInfo.new("energy_percent", TYPE_FLOAT,
			"Cell's current energy as a percentage of it's maximum energy. Range: 0.0 to 1.0"), 
		CellAttributeInfo.new("age", TYPE_INT,
			"Number of simulation steps completed since the cell was created."), 
		CellAttributeInfo.new("generation", TYPE_INT,
			"Number of cells of the same type produced before this cell.")
	]
	for gene_config:GeneConfig in gene_configs:
		names.append_array(gene_config.gene_type.get_cell_attribute_list())
	return names

func _to_string() -> String:
	return "CellType:%s:%s" % [genome.name, name]
	
func instantiate_cell_appearance() -> CellAppearance:
	var cell_appearance := genome.appearance_set.cell_appearances[cell_appearance_index]
	var instance:CellAppearance = cell_appearance.instantiate()
	instance.cell_type = self
	return instance

func is_correct_cell_appearance(cell_appearance:CellAppearance) -> bool:
	var actual_cell_appearance := genome.appearance_set.cell_appearances[cell_appearance_index]
	return cell_appearance != null and cell_appearance.scene_file_path == actual_cell_appearance.resource_path
