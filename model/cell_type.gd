class_name CellType extends RefCounted

var genome:Genome
var name:String = '(new cell type)'
var gene_configs:Array[GeneConfig] = []
var cell_appearance:PackedScene
var energy_cost:int = 0

func _init(genome_:Genome, cell_appearance_:PackedScene = genome_.appearance_set.get_default_cell_appearance()):
	genome = genome_
	cell_appearance = cell_appearance_
	
func add_gene_config(gene_config:GeneConfig) -> void:
	gene_configs.append(gene_config)
	
func add_gene_type(gene_type:Script) -> GeneConfig:
	var gene_config = gene_type.create_config(self)
	add_gene_config(gene_config)
	return gene_config
	
func remove_gene_type(gene_type:Script) -> void:
	gene_configs = gene_configs.filter(
		func (gene_config:GeneConfig): 
			return gene_config.gene_type != gene_type)
	
func remove_gene_config(gene_config:GeneConfig) -> void:
	gene_configs.erase(gene_config)
	
func create_cell(progenitor:Cell = null) -> Cell:
	var cell:Cell = Cell.new(self)
	cell.genes.assign(
		gene_configs.map(
			func (gene_config:GeneConfig): 
				return gene_config.gene_type.create_gene(progenitor, gene_config)))
	return cell
