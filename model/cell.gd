class_name Cell extends RefCounted

static var _next_cell_number:int = 1
static func get_next_cell_number() -> int:
	var cell_number = _next_cell_number
	_next_cell_number += 1
	return cell_number

var _genome:Genome = null
var genome:Genome:
	get: return _genome
	
var _cell_type:CellType = null
var cell_type:CellType:
	get: return _cell_type

var energy:float = 0.0
var gene_state:Dictionary[Gene, Variant] = {}

var _cell_number:int = get_next_cell_number()

var _cell_appearance:CellAppearance

func _init(cell_type:CellType):
	_cell_type = cell_type
	_genome = _cell_type.genome

func use_energy(index:HexIndex, world:World) -> void:
	for gene in cell_type.active_genes:
		gene.use_energy(index, world, self)
	
func aquire_energy(index:HexIndex, world:World) -> void:
	for gene in cell_type.active_genes:
		gene.aquire_energy(index, world, self)

func resolve_conflicting_create(other:Cell) -> Cell:
	return other

func _to_string() -> String:
	return "Cell:%s:%s:%d:%d" % [_genome.name, _cell_type.name, _cell_number, energy]

func serialize(genome_map:Dictionary[Genome, Variant]) -> Variant:
	
	var mapped_gene_state = {}
	for gene in gene_state.keys():
		var gene_index = _cell_type.active_genes.find(gene)
		mapped_gene_state.seet(gene_index, gene_state[gene])
		
	return {
		energy = energy,
		genome = genome_map[genome],
		cell_type = genome.cell_types.find(cell_type),
		gene_state = mapped_gene_state
	}
	
static func deserialize(data:Variant, genome_map:Dictionary[Variant, Genome]) -> Cell:
	
	var genome:Genome = genome_map[data['genome']]
	
	var cell = Cell.new(
		genome.cell_types[data['cell_type']]
	)
	
	cell.energy = data['energy']
	
	var mapped_gene_state = data['gene_state']
	for gene_index in mapped_gene_state.keys():
		var gene = cell._cell_type.active_genes[gene_index]
		cell.gene_state[gene] = mapped_gene_state[gene_index]
		
	return cell
	
func get_cell_appearance() -> CellAppearance:
	if _cell_appearance == null:
		_cell_appearance = _cell_type.cell_appearance.clone()
	return _cell_appearance
