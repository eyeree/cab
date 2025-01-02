class_name ProduceCellGene extends Gene
	
class ProduceCellGeneConfig extends GeneConfig:
	var cell_type:CellType
	
	func _init(cell_type_:CellType):
		cell_type = cell_type_
	
class ProduceCellGeneState extends GeneState:
	
	var _cell_type:CellType
	
	func _init(config:ProduceCellGeneConfig):
		_cell_type = config.cell_type

func _init():
	name = 'ProduceCell'
	
func create_config(cell_type:CellType) -> ProduceCellGeneConfig:
	return ProduceCellGeneConfig.new(cell_type)

func create_state(progenitor:Cell, config:GeneConfig) -> GeneState:
	
	if config is not ProduceCellGeneConfig:
		push_error('wrong config type passed to gene %s create_state: %s' % [name, config])
		return super.create_state(progenitor, config)
		
	return ProduceCellGeneState.new(config)
	
