class_name Genome extends Resource

@export var name:String = '(new genone)'
@export var appearance_set:AppearanceSet
var gene_types:Array[GeneType] = []
@export var cell_types:Array[CellType] = []
@export var hidden:bool = false

static var _genome_refs:Array[WeakRef] = []
static func get_cell_type_genome(cell_type:CellType) -> Genome:
	for genome_ref in _genome_refs:
		var genome = genome_ref.get_ref()
		if genome:
			if genome.cell_types.has(cell_type):
				return genome
	return null

func _init() -> void:
	_genome_refs.append(weakref(self))
	appearance_set = AppearanceSet.default

func add_gene(gene_class:Script) -> void:
	add_gene_type(GeneType.for_gene_class(gene_class))
	
func add_gene_type(gene_type:GeneType) -> void:
	if not gene_types.has(gene_type):
		gene_types.append(gene_type)
		
func remove_gene_type(gene_type:GeneType) -> void:
	if not is_gene_type_used(gene_type):
		gene_types.erase(gene_type)

func is_gene_type_used(gene_type:GeneType) -> bool:
	for cell_type in cell_types:
		if cell_type.has_gene_type(gene_type):
			return true
	return false
	
func add_cell_type() -> CellType:
	var cell_type = CellType.new()
	cell_types.append(cell_type)
	return cell_type
	
func remove_cell_type(cell_type:CellType) -> void:
	cell_types.erase(cell_type)

func validate():
	for cell_type in cell_types:
		if not appearance_set.has_cell_appearance(cell_type.cell_appearance):
			push_error("Cell type %s cell appearance %s not found in appearance set %s." % [cell_type, appearance_set])
		for gene_config in cell_type.gene_configs:
			if not has_gene_type(gene_config.gene_type):
				push_error("Cell type %s active gene %s not found in genome gene_types." % [cell_type, gene_config.gene_type])
			
func has_gene_type(gene_type:GeneType) -> bool:
	return gene_types.any(func (entry): return entry == gene_type)
	
func get_cell_type_rank(cell_type:CellType) -> int:
	var index = cell_types.find(cell_type)
	if index == -1:
		push_error('cell type %s not part of genome %s' % [cell_type, self])
	return index
	
func get_cell_type(cell_type_name:String) -> CellType:
	for cell_type in cell_types:
		if cell_type.name == cell_type_name:
			return cell_type
	return null

func get_energy_cost() -> int:
	var energy_cost := 0
	for cell_type in cell_types:
		energy_cost += cell_type.get_energy_cost()
	return energy_cost
