class_name Cell extends RefCounted

var genome:Genome
var cell_type:CellType
var cell_appearance:CellAppearance

var cell_number:int

var energy:float = 0.0
var health:float = 1.0
var gene_states:Array[GeneState] = []

func _init(cell_type_:CellType) -> void:
	genome = cell_type.genome
	cell_type = cell_type_
	cell_appearance = cell_type.cell_appearance.clone()

func perform_actions(index:HexIndex, world:World) -> void:
	for gene_state in gene_states:
		gene_state.perform_actions(index, world, self)
	
func update_state(index:HexIndex, world:World) -> void:
	for gene_state in gene_states:
		gene_state.update_state(index, world, self)

func _to_string() -> String:
	return "Cell:%s:%s:%d:%0.0f:%0.2f" % [genome.name, cell_type.name, cell_number, energy, health]
