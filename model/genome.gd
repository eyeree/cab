class_name Genome extends RefCounted

static var _serialization = SerializationUtil.register(Genome)

var name:String = '(new genone)'
var appearance_set:AppearanceSet
var genes:Array[Gene] = []
var cell_types:Array[CellType] = []

func _on_deserialized():
	for cell_type:CellType in cell_types:
		cell_type.genome = self
		
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
	
