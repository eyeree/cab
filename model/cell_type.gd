class_name CellType extends RefCounted

static func _static_init():
	SerializationUtil.register(CellType, {
		Activation = Activation
	})

class Activation extends RefCounted:
	var gene:Gene
	var config:GeneConfig

var genome:Genome
var name:String = '(new cell type)'
var activations:Array[Activation]
var cell_appearance:CellAppearance

func create_cell(creator:Cell = null) -> Cell:
	var cell:Cell = Cell.new()
	cell.genome = self.genome
	cell.cell_type = self
	cell.cell_appearance = cell_appearance.clone()
	cell.gene_state = activations.map(
		func (activation:Activation):
			var gene_state:GeneState = activation.gene.create_state(creator, activation.config)
			gene_state.gene = activation.gene
			gene_state.cell = cell
			return gene_state
	)
	return cell
