class_name CellType extends RefCounted

var genome:Genome
var name:String = '(new cell type)'
var gene_configs:Array[GeneConfig] = []
var cell_appearance:PackedScene

var energy_cost:int:
	get:
		var total = 0
		for gene_config in gene_configs:
			total += gene_config.get_energy_cost()
		return total

func _init(genome_:Genome, cell_appearance_:PackedScene = genome_.appearance_set.get_default_cell_appearance()):
	genome = genome_
	cell_appearance = cell_appearance_
	
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
	return add_gene_type(gene_class.gene_type_)	

func has_gene(gene_class:Script) -> bool:
	return has_gene_type(gene_class.gene_type_)
	
func create_cell(progenitor:Cell = null, cell_state:CellState = null) -> Cell:
	var new_cell:Cell = Cell.new(progenitor, self, cell_state)
	if progenitor != null and progenitor.cell_type == self:
		new_cell.generation = progenitor.generation + 1		
	return new_cell
	
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
