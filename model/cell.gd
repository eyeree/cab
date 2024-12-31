class_name Cell extends RefCounted

static var _serialization = SerializationUtil.register(Cell) \
	.ignore_properties(Cell, ['genome'])

static var _next_cell_number:int = 1
static func get_next_cell_number() -> int:
	var cell_number = _next_cell_number
	_next_cell_number += 1
	return cell_number

var genome:Genome
var cell_type:CellType
var cell_appearance:CellAppearance

var cell_number:int = get_next_cell_number()

var energy:float = 0.0
var gene_states:Array[GeneState] = []

func _on_deserialized():
	for gene_state:GeneState in gene_states:
		gene_state.cell = self

func use_energy(index:HexIndex, world:World) -> void:
	for gene_state in gene_states:
		gene_state.use_energy(index, world, self)
	
func aquire_energy(index:HexIndex, world:World) -> void:
	for gene_state in gene_states:
		gene_state.aquire_energy(index, world, self)

func resolve_conflicting_create(other:Cell) -> Cell:
	return other

func _to_string() -> String:
	return "Cell:%s:%s:%d:%d" % [genome.name, cell_type.name, cell_number, energy]
