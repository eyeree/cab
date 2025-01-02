class_name CellType extends RefCounted

class Activation extends RefCounted:
	
	var gene:Gene
	var config:GeneConfig
	
	func _init(gene_:Gene, config_:GeneConfig):
		gene = gene_
		config = config_

var genome:Genome
var name:String = '(new cell type)'
var activations:Array[Activation] = []
var cell_appearance:CellAppearance

func _init(genome_:Genome, cell_appearance_:CellAppearance = genome_.appearance_set.get_default_cell_appearance()):
	genome = genome_
	cell_appearance = cell_appearance_
	
func add_active_gene(gene:Gene) -> Activation:
	var activation = get_activation_for_gene(gene)
	if activation == null:
		var config = gene.create_config(self)
		activation = Activation.new(gene, config)
		activations.append(activation)
	return activation
	
func remove_active_gene(gene:Gene) -> void:
	var activation = get_activation_for_gene(gene)
	if activation != null:
		remove_activation(activation)
	
func remove_activation(activation:Activation) -> void:
	activations.erase(activation)
	
func get_activation_for_gene(gene:Gene) -> Activation:
	for activation in activations:
		if activation.gene == gene:
			return activation
	return null	
	
func create_cell(progenitor:Cell = null) -> Cell:
	var cell:Cell = Cell.new(self)
	cell.gene_state = activations.map(
		func (activation:Activation):
			return activation.gene.create_state(progenitor, activation.config)
	)
	return cell
