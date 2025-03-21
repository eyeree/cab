class_name GenesPanel extends PanelContainer

@onready var _cell_type_name_value_label: Label = %CellTypeNameValueLabel
@onready var _genome_name_value_label: Label = %GenomeNameValueLabel
@onready var _energy_cost_value_label: Label = %EnergyCostValueLabel
@onready var _one_gene_minimum_container: MarginContainer = %OneGeneMinimumContainer
@onready var _gene_container: VBoxContainer = %GeneContainer
@onready var _add_gene_button: MenuButton = %AddGeneButton
@onready var _no_selection_container: VBoxContainer = %NoSelectionContainer
@onready var _selection_container: VBoxContainer = %SelectionContainer

var _cell_type:CellType

func _ready() -> void:
	Level.signals.current_level_modified.connect(_on_current_level_modified)
	_add_gene_button.get_popup().index_pressed.connect(_on_add_gene_button_index_pressed)

func show_cell_type(cell_type_:CellType) -> void:
	_cell_type = cell_type_
	if _cell_type:
		_selection_container.visible = true
		_no_selection_container.visible = false
		_update_controls()
	else:
		_selection_container.visible = false
		_no_selection_container.visible = true

	
func _on_current_level_modified() -> void:
	if _cell_type:
		_update_controls()
	
func _update_controls() -> void:
	_cell_type_name_value_label.text = _cell_type.name
	_genome_name_value_label.text = _cell_type.genome.name
	_energy_cost_value_label.text = str(_cell_type.get_energy_cost())
	_one_gene_minimum_container.visible = _cell_type.gene_configs.size() == 0
	_show_genes(_cell_type.gene_configs)
	
func _clear_genes() -> void:
	for child in _gene_container.get_children():
		child.visible = false
		# deferred to avoid timer error when spin button is removed from tree while clicked
		_remove_child.call_deferred(child) 
		
func _remove_child(child:Node) -> void:
		_gene_container.remove_child(child)
		child.queue_free()
	
func _show_genes(gene_configs:Array[GeneConfig]) -> void:
	_clear_genes()
	for gene_config in gene_configs:
		var gene_config_panel := gene_config.gene_type.get_gene_config_panel()
		if gene_config_panel:
			_gene_container.add_child(gene_config_panel)
			gene_config_panel.show_gene_config(gene_config)

func _on_add_gene_button_index_pressed(index:int) -> void:
	prints('index', index)
