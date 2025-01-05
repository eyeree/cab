class_name EnvionmentGenome extends Genome

static var genome:Genome

static var bounds_cell_type:CellType
static var empty_cell_type:CellType
static var food_cell_type:CellType
static var toxin_cell_type:CellType

static func _static_init() -> void:
	
	genome = Genome.new()
	genome.name = 'Envionment'
	genome.hidden = true
	genome.appearance_set = load("res://appearance/environment/environment_appearance_set.tres")
	genome.gene_types.append_array([
		ResistDamageGene.gene_type, 
		ClaimableCellGene.gene_type,
		ProvideFoodGene.gene_type,
		ProduceToxinGene.gene_type
	])
	
	bounds_cell_type = genome.add_cell_type()
	bounds_cell_type.name = 'Bounds'
	bounds_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('environment_cell_bounds')
	bounds_cell_type.add_gene_config(ResistDamageGene.damage_immunity_config)
	
	empty_cell_type = genome.add_cell_type()
	empty_cell_type.name = 'Empty'
	empty_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('environment_cell_empty')
	empty_cell_type.add_gene_config(ResistDamageGene.damage_immunity_config)
	empty_cell_type.add_gene_type(ClaimableCellGene.gene_type)
	
	food_cell_type = genome.add_cell_type()
	food_cell_type.name = 'Food'
	food_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('environment_cell_food')
	food_cell_type.add_gene_config(ResistDamageGene.damage_immunity_config)
	food_cell_type.add_gene_type(ProvideFoodGene.gene_type)

	toxin_cell_type = genome.add_cell_type()
	toxin_cell_type.name = 'Toxin'
	toxin_cell_type.cell_appearance = genome.appearance_set.get_cell_appearance_by_name('environment_cell_toxin')
	toxin_cell_type.add_gene_config(ResistDamageGene.damage_immunity_config)
	toxin_cell_type.add_gene_type(ProduceToxinGene.gene_type)
