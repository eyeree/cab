class_name CellType extends RefCounted

var genome:Genome
var name:String = '(new cell type)'
var active_genes:Array[Gene]
var cell_appearance:CellAppearance

func _init(genome_:Genome):
	genome = genome_
	
func serialize() -> Variant:
	return {
		name = name,
		active_genes = active_genes.map(func (gene): return gene.serialize()),
		cell_appearance = cell_appearance.serialize()
	}

static func deserialize(data:Variant, genome_:Genome) -> CellType:
	var cell_type:CellType = CellType.new(genome_)
	cell_type.name = data['name']
	cell_type.active_genes = data['active_genes'].map(func (entry): return Gene.deserialize(entry))
	cell_type.cell_appearance = CellAppearance.deserialize(data['cell_appearance'])
	return cell_type

func create_cell() -> Cell:
	return Cell.new(self)
