class_name GenomePanel extends PanelContainer

@onready var _cell_types_toggle_button: Button = %CellTypesToggleButton
@onready var _genome_name: LineEdit = %GenomeName
@onready var _remove_genome_button: Button = %RemoveGenomeButton
@onready var _cell_type_container: VBoxContainer = %CellTypeContainer
@onready var _on_add_cell_type_button_pressed_button: Button = %AddCellTypeButton
@onready var _confirm_remove_genome_button: Button = %ConfirmRemoveGenomeButton
@onready var _cancel_remove_genome_button: Button = %CancelRemoveGenomeButton
@onready var _confirm_remove_genome_popup: PopupPanel = %ConfirmRemoveGenomePopup
@onready var _confirm_remove_genome_name: Label = %ConfirmRemoveGenomeName

const ARROW_DOWN := preload("res://icon/arrow_down.svg")
const ARROW_RIGHT := preload("res://icon/arrow_right.svg")
const CELL_TYPE_PANEL := preload("res://main/genomes_panel/cell_type_panel.tscn")

var genome:Genome

class GenomePanelSignals:
	
	@warning_ignore("unused_signal")
	signal remove_genome(genome:Genome)

static var signals := GenomePanelSignals.new()	

func _ready() -> void:
	_cell_types_toggle_button.pressed.connect(_toggle_cell_types)
	_remove_genome_button.pressed.connect(_on_remove_genome_button_pressed)
	_on_add_cell_type_button_pressed_button.pressed.connect(_on_add_cell_type_button_pressed)
	_genome_name.text_changed.connect(_on_genome_name_text_changed)
	_confirm_remove_genome_button.pressed.connect(_on_confirm_remove_genome_button_pressed)
	_cancel_remove_genome_button.pressed.connect(_on_cancel_remove_genome_button_pressed)
	
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
		cell_type_panel.queue_free()
	for cell_type in genome.cell_types:
		var cell_type_panel:CellTypePanel = CELL_TYPE_PANEL.instantiate()
		_cell_type_container.add_child(cell_type_panel)
		_cell_type_container.move_child(cell_type_panel, -2)
		cell_type_panel.show_cell_type(cell_type)
		
func _on_add_cell_type_button_pressed() -> void:
	var cell_type := genome.add_cell_type()
	var cell_type_panel:CellTypePanel = CELL_TYPE_PANEL.instantiate()
	_cell_type_container.add_child(cell_type_panel)
	_cell_type_container.move_child(cell_type_panel, -2)
	cell_type_panel.show_cell_type(cell_type)
	CellTypePanel.signals.cell_type_selected.emit(cell_type)
	Level.current.level_modified.emit()

func _on_remove_genome_button_pressed() -> void:
	_confirm_remove_genome_name.text = '"%s"' % [genome.name]
	_confirm_remove_genome_popup.reset_size()
	_confirm_remove_genome_popup.show()
	
func _on_genome_name_text_changed(new_text:String) -> void:
	genome.name = new_text
	Level.current.level_modified.emit()

func _on_cancel_remove_genome_button_pressed() -> void:
	_confirm_remove_genome_popup.hide()
	
func _on_confirm_remove_genome_button_pressed() -> void:
	_confirm_remove_genome_popup.hide()
	for index in Level.current.content.get_all_indexes():
		var content = Level.current.content.get_content(index)
		if content is CellType and content.genome == genome:
			Level.current.content.clear_content(index)
	Level.current.genomes.erase(genome)
	Level.current.level_modified.emit()
	# deffered to avoid error: 
	#   E 0:00:09:420   _push_unhandled_input_internal: Condition "!is_inside_tree()" is true.
	#   <C++ Source>  scene/main/viewport.cpp:3338 @ _push_unhandled_input_internal()
	_remove_self.call_deferred() 
	
func _remove_self() -> void:
	get_parent().remove_child(self)
	queue_free()
