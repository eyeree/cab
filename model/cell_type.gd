class_name CellType extends RefCounted

static var _serializers = SerializationUtil.register(CellType, {
	Activation = Activation
})

class Activation extends RefCounted:
	
	var gene:Gene
	var config:GeneConfig
	
	func _init(gene_:Gene, config_:GeneConfig):
		gene = gene_
		config = config_
		
	func serialize() -> Variant:
		return {
			gene = gene.serialize_ref(),
			config = config.serialize()
		}
		
	static func deserialize(data:Variant) -> Activation:
		var gene:Gene = Gene.deserialize_ref(data['gene'])
		var config:GeneConfig = gene.deserialize_config(data['config'])
		return Activation.new(gene, config)

var genome:Genome
var name:String = '(new cell type)'
var activations:Array[Activation]
var cell_appearance:CellAppearance

func _init(genome_:Genome):
	genome = genome_
	
func serialize() -> Variant:
	return {
		name = name,
		activations = activations.map(
			func (activation:Activation): 
				return activation.serialize()),
		cell_appearance = cell_appearance.serialize_ref()
	}

static func deserialize(data:Variant, genome_:Genome) -> CellType:
	var cell_type:CellType = CellType.new(genome_)
	cell_type.name = data['name']
	cell_type.activations = data['activations'].map(
		func (entry:Dictionary):	 
			return Activation.deserialize(entry))
	cell_type.cell_appearance = CellAppearance.deserialize_ref(data['cell_appearance'])
	return cell_type

func create_cell(creator:Cell = null) -> Cell:
	var cell:Cell = Cell.new(self)
	cell.gene_state = activations.map(
		func (activation:Activation):
			var gene_state:GeneState = activation.gene.create_state(creator, activation.config)
			gene_state.gene = activation.gene
			gene_state.cell = cell
			return gene_state
	)
	return cell
