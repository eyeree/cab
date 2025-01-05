class_name CellType extends RefCounted

var genome:Genome
var name:String = '(new cell type)'
var gene_configs:Array[GeneConfig] = []
var cell_appearance:PackedScene
var energy_cost:int:
	get:
		var total = 0
		for gene_config in gene_configs:
			total += gene_config.gene_type.energy_cost
		return total

func _init(genome_:Genome, cell_appearance_:PackedScene = genome_.appearance_set.get_default_cell_appearance()):
	genome = genome_
	cell_appearance = cell_appearance_
	
func add_gene_config(gene_config:GeneConfig) -> void:
	prints('add_gene_config', gene_config.gene_type.name)
	gene_configs.append(gene_config)
	
func add_gene_type(gene_type:GeneType) -> GeneConfig:
	prints('add_gene_type', gene_type.name)
	var gene_config = gene_type.create_config(self)
	prints('  gene_config.gene_type', gene_config.gene_type.name)
	add_gene_config(gene_config)
	return gene_config
	
func remove_gene_type(gene_type:GeneType) -> void:
	gene_configs = gene_configs.filter(
		func (gene_config:GeneConfig): 
			return gene_config.gene_type != gene_type)

func has_gene_type(gene_type:GeneType) -> bool:
	for gene_config in gene_configs:
		if gene_config.gene_type == gene_type:
			return true
	return false
			
func remove_gene_config(gene_config:GeneConfig) -> void:
	gene_configs.erase(gene_config)
	
func create_cell(progenitor:Cell = null) -> Cell:
	return Cell.new(progenitor, self)
