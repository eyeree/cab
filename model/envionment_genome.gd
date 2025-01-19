class_name EnvironmentGenome extends Genome

static var genome:Genome

static var bounds_cell_type:CellType
static var empty_cell_type:CellType
static var food_cell_type:CellType
static var toxin_cell_type:CellType

static func _static_init() -> void:
	
	GeneType.get_all_gene_types() # force load
	
	genome = Genome.new()
	genome.name = 'Environment'
	genome.hidden = true
	genome.appearance_set = preload("res://appearance/environment/environment_appearance_set.tres")
	genome.add_gene(ImmortalityGene)
	genome.add_gene(ClaimableCellGene)
	genome.add_gene(ProvideFoodGene)
	genome.add_gene(ProduceToxinGene)
	
	bounds_cell_type = genome.add_cell_type()
	bounds_cell_type.name = 'Bounds'
	bounds_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('environment_cell_bounds')
	bounds_cell_type.add_gene(ImmortalityGene)
	
	empty_cell_type = genome.add_cell_type()
	empty_cell_type.name = 'Empty'
	empty_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('environment_cell_empty')
	empty_cell_type.add_gene(ImmortalityGene)
	empty_cell_type.add_gene(ClaimableCellGene)
	
	food_cell_type = genome.add_cell_type()
	food_cell_type.name = 'Food'
	food_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('environment_cell_food')
	food_cell_type.add_gene(ImmortalityGene)
	food_cell_type.add_gene(ProvideFoodGene)

	toxin_cell_type = genome.add_cell_type()
	toxin_cell_type.name = 'Toxin'
	toxin_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('environment_cell_toxin')
	toxin_cell_type.add_gene(ImmortalityGene)
	toxin_cell_type.add_gene(ProduceToxinGene)
