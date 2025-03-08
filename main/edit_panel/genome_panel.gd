class_name GenomePanel extends PanelContainer

@onready var _cell_types_toggle_button: Button = %CellTypesToggleButton
@onready var _genome_name: Label = %GenomeName
@onready var _delete_genome_button: Button = %DeleteGenomeButton
@onready var _cell_type_container: VBoxContainer = %CellTypeContainer
@onready var _add_cell_type_button: Button = %AddCellTypeButton

const ARROW_DOWN := preload("res://icon/arrow_down.svg")
const ARROW_RIGHT := preload("res://icon/arrow_right.svg")
const CELL_TYPE_PANEL := preload("res://main/edit_panel/cell_type_panel.tscn")

signal remove_genome(genome:Genome)
signal cell_type_selected(cell_type:CellType)

var genome:Genome
var _selected_cell_type_panel:CellTypePanel = null

func _ready() -> void:
	_cell_types_toggle_button.pressed.connect(_toggle_cell_types)
	_delete_genome_button.pressed.connect(func (): remove_genome.emit(genome))
	_add_cell_type_button.pressed.connect(_add_cell_type)
	
func _toggle_cell_types() -> void:
	if _cell_type_container.visible:
		_cell_type_container.visible = false
		_cell_types_toggle_button.icon = ARROW_RIGHT
	else:
		_cell_type_container.visible = true
		_cell_types_toggle_button.icon = ARROW_DOWN

func show_genome(genome_:Genome) -> void:
	genome = genome_
	_genome_name.text = genome.name
	for cell_type_panel:CellTypePanel in _cell_type_container.get_children().slice(0, -1):
		_cell_type_container.reemove_child(cell_type_panel)
		cell_type_panel.delete_cell_type.disconnect(_delete_cell_type)
		cell_type_panel.cell_type_clicked.disconnect(_cell_type_clicked)
		cell_type_panel.queue_free()
	for cell_type in genome.cell_types:
		var cell_type_panel:CellTypePanel = CELL_TYPE_PANEL.instantiate()
		_cell_type_container.add_child(cell_type_panel)
		_cell_type_container.move_child(cell_type_panel, -2)
		cell_type_panel.delete_cell_type.connect(_delete_cell_type)
		cell_type_panel.cell_type_clicked.connect(_cell_type_clicked)
		cell_type_panel.show_cell_type(cell_type)
		
func _delete_cell_type(cell_type:CellType) -> void:
	genome.remove_cell_type(cell_type)
	var i = _cell_type_container.get_children().find_custom(
		func (child): 
			return child is CellTypePanel and child.cell_type == cell_type)
	var cell_type_panel:CellTypePanel = _cell_type_container.get_child(i)
	_cell_type_container.remove_child(cell_type_panel)
	cell_type_panel.delete_cell_type.disconnect(_delete_cell_type)
	cell_type_panel.cell_type_clicked.disconnect(_cell_type_clicked)
	if cell_type_panel.selected:
		if _cell_type_container.get_child_count() == 1:
			_cell_type_clicked(null)
		else:
			var j = i - 1 if i == _cell_type_container.get_child_count() - 1 else i
			var selected_cell_type_panel = _cell_type_container.get_child(j)
			_cell_type_clicked(selected_cell_type_panel.cell_type)
	cell_type_panel.queue_free()
	
func _add_cell_type() -> void:
	var cell_type := genome.add_cell_type()
	var cell_type_panel:CellTypePanel = CELL_TYPE_PANEL.instantiate()
	_cell_type_container.add_child(cell_type_panel)
	_cell_type_container.move_child(cell_type_panel, -2)
	cell_type_panel.delete_cell_type.connect(_delete_cell_type)
	cell_type_panel.cell_type_clicked.connect(_cell_type_clicked)
	cell_type_panel.show_cell_type(cell_type)
	_cell_type_clicked(cell_type)

func _cell_type_clicked(cell_type:CellType):
	if _selected_cell_type_panel:
		_selected_cell_type_panel.selected = false
	if cell_type == null:
		_selected_cell_type_panel = null
		cell_type_selected.emit(null)
	else:
		var i = _cell_type_container.get_children().find_custom(
			func (child): 
				return child is CellTypePanel and child.cell_type == cell_type)
		_selected_cell_type_panel = _cell_type_container.get_child(i)
		_selected_cell_type_panel.selected = true
		cell_type_selected.emit(_selected_cell_type_panel.cell_type)

func clear_cell_type_selection() -> void:
	if _selected_cell_type_panel:
		_selected_cell_type_panel.selected = false
		_selected_cell_type_panel = null
