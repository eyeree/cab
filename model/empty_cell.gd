class_name EmptyCell extends Cell

static var _empty_cell_genome:Genome = Genome.new()
static var _empty_cell_type:CellType = CellType.new()

func _init():
	super(_empty_cell_genome, _empty_cell_type)
