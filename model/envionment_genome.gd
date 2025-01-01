class_name EnvionmentGenome extends Genome

static var genome:Genome
static var bounds_cell_type:CellType
static var empty_cell_type:CellType
static var agar_cell_type:CellType
static var food_cell_type:CellType
static var toxin_cell_type:CellType

static func _static_init() -> void:
	
	genome = Genome.new()
	genome.name = 'Envionment'
	genome.appearance_set = load("res://appearance/environment/environment_appearance_set.tres")
	
	bounds_cell_type = genome.add_cell_type()
	bounds_cell_type.name = 'Bounds'
	bounds_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('Bounds')
	
	empty_cell_type = genome.add_cell_type()
	empty_cell_type.name = 'Empty'
	empty_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('Empty')

	agar_cell_type = genome.add_cell_type()
	agar_cell_type.name = 'Agar'
	agar_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('Agar')
	
	food_cell_type = genome.add_cell_type()
	food_cell_type.name = 'Food'
	food_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('Food')

	toxin_cell_type = genome.add_cell_type()
	toxin_cell_type.name = 'Toxin'
	toxin_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('Toxin')
