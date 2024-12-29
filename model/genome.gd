class_name Genome extends RefCounted

var name:String = '(new genone)'
var appearance_set:AppearanceSet
var genes:Array[Gene] = []
var cell_types:Array[CellType] = []

func serialize() -> Variant:
	return {
		name = name,
		appearance_set = appearance_set.serialize(),
		genes = genes.map(func (gene): return gene.serialize()),
		cell_types = cell_types.map(func (cell_type): cell_type.serialize())
	}
	
static func deserialize(data:Variant) -> Genome:
	var genome:Genome = Genome.new()
	genome.name = data['name']
	genome.appearance_set = AppearanceSet.deserialize(data['appearance_set'])
	genome.genes = data['genes'].map(func (entry): return Gene.deserialize(entry))
	genome.cell_types = data['cell_types'].map(func (entry): return CellType.deserialize(entry, genome))
	genome.validate()
	return genome
	
func validate():
	var errors:Array[String] = []
	for cell_type in cell_types:
		if not appearance_set.has_cell_appearance(cell_type.cell_appearance):
			push_error("Cell type %s cell appearance %s not found in appearance set %s." % [cell_type, appearance_set])
		for gene in cell_type.active_genes:
			if not has_gene(gene):
				push_error("Cell type %s active gene %s not found in genome genes." % [cell_type, gene])
			
func has_gene(gene:Gene) -> bool:
	return genes.any(func (entry): return entry == gene)
	
