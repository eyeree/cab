class_name Genome extends RefCounted

var name:String = '(new genone)'
var appearance_set:AppearanceSet
var gene_types:Array[GeneType] = []
var cell_types:Array[CellType] = []
var hidden:bool = false

func _init() -> void:
	appearance_set = AppearanceSet.default

func add_gene(gene_class:Script) -> void:
	add_gene_type(gene_class.gene_type_)
	
func add_gene_type(gene_type:GeneType) -> void:
	if not gene_types.has(gene_type):
		gene_types.append(gene_type)
		
func remove_gene_type(gene_type:GeneType) -> void:
	if not is_gene_type_used(gene_type):
		gene_types.erase(gene_type)

func is_gene_type_used(gene_type:GeneType) -> bool:
	for cell_type in cell_types:
		if cell_type.has_gene_type(gene_type):
			return true
	return false
	
func add_cell_type() -> CellType:
	var cell_type = CellType.new(self)
	cell_types.append(cell_type)
	return cell_type
	
func remove_cell_type(cell_type:CellType) -> void:
	cell_types.erase(cell_type)

func validate():
	for cell_type in cell_types:
		if not appearance_set.has_cell_appearance(cell_type.cell_appearance):
			push_error("Cell type %s cell appearance %s not found in appearance set %s." % [cell_type, appearance_set])
		for gene_config in cell_type.gene_configs:
			if not has_gene_type(gene_config.gene_type):
				push_error("Cell type %s active gene %s not found in genome gene_types." % [cell_type, gene_config.gene_type])
			
func has_gene_type(gene_type:GeneType) -> bool:
	return gene_types.any(func (entry): return entry == gene_type)
	
