class_name Genome extends RefCounted

var name:String = '(new genone)'
var appearance_set:AppearanceSet = AppearanceSet.default
var genes:Array[Gene] = []
var cell_types:Array[CellType] = []
var hidden:bool = false

func _init() -> void:
	pass

func add_gene(gene:Gene) -> void:
	if not genes.has(gene):
		genes.append(gene)
		
func remove_gene(gene:Gene) -> void:
	if not is_gene_used(gene):
		genes.erase(gene)

func is_gene_used(gene:Gene) -> bool:
	for cell_type in cell_types:
		if cell_type.is_gene_active(gene):
			return true
	return false
	
func add_cell_type() -> CellType:
	var cell_type = CellType.new(self)
	cell_types.append(cell_type)
	return cell_type
	
func remove_cell_type(cell_type:CellType) -> void:
	cell_types.erase(cell_type)

func validate():
	var errors:Array[String] = []
	for cell_type in cell_types:
		if not appearance_set.has_cell_appearance(cell_type.cell_appearance):
			push_error("Cell type %s cell appearance %s not found in appearance set %s." % [cell_type, appearance_set])
		for active_gene in cell_type.active_genes:
			if not has_gene(active_gene.gene):
				push_error("Cell type %s active gene %s not found in genome genes." % [cell_type, active_gene.gene])
			
func has_gene(gene:Gene) -> bool:
	return genes.any(func (entry): return entry == gene)
	
