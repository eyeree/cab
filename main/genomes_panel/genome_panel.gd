class_name GenomePanel extends PanelContainer

@onready var _toggle_button: Button = %ToggleButton
@onready var _genome_name: LineEdit = %GenomeName
@onready var _remove_genome_button: Button = %RemoveGenomeButton
@onready var _cell_type_container: VBoxContainer = %CellTypeContainer
@onready var _on_add_cell_type_button_pressed_button: Button = %AddCellTypeButton
@onready var _confirm_remove_genome_button: Button = %ConfirmRemoveGenomeButton
@onready var _cancel_remove_genome_button: Button = %CancelRemoveGenomeButton
@onready var _confirm_remove_genome_popup: PopupPanel = %ConfirmRemoveGenomePopup
@onready var _confirm_remove_genome_name: Label = %ConfirmRemoveGenomeName
@onready var _appearance_set_option_button: OptionButton = %AppearanceSetOptionButton
@onready var _toggled_container: MarginContainer = %ToggledContainer
@onready var _energy_cost_value_label: Label = %EnergyCostValueLabel

const ARROW_DOWN := preload("res://icon/arrow_down.svg")
const ARROW_RIGHT := preload("res://icon/arrow_right.svg")
const CELL_TYPE_PANEL := preload("res://main/genomes_panel/cell_type_panel.tscn")

var genome:Genome

class GenomePanelSignals:
	
	@warning_ignore("unused_signal")
	signal remove_genome(genome:Genome)

static var signals := GenomePanelSignals.new()	

func _ready() -> void:
	_toggle_button.pressed.connect(_on_toggle_button_pressed)
	_remove_genome_button.pressed.connect(_on_remove_genome_button_pressed)
	_on_add_cell_type_button_pressed_button.pressed.connect(_on_add_cell_type_button_pressed)
	_genome_name.text_changed.connect(_on_genome_name_text_changed)
	_confirm_remove_genome_button.pressed.connect(_on_confirm_remove_genome_button_pressed)
	_cancel_remove_genome_button.pressed.connect(_on_cancel_remove_genome_button_pressed)
	_appearance_set_option_button.item_selected.connect(_on_appearance_set_option_button_item_selected)
	Level.signals.current_level_modified.connect(_on_current_level_modified)
	_confirm_remove_genome_popup.popup_hide.connect(_on_confirm_remove_genome_popup_popup_hide)
	
	for appearance_set in AppearanceSet.get_all_appearance_sets():
		if not appearance_set.hidden:
			_appearance_set_option_button.add_item(appearance_set.name)
	
func _on_toggle_button_pressed() -> void:
	if _toggled_container.visible:
		_toggled_container.visible = false
		_toggle_button.icon = ARROW_RIGHT
	else:
		_toggled_container.visible = true
		_toggle_button.icon = ARROW_DOWN

func show_genome(genome_:Genome) -> void:
	genome = genome_
	_genome_name.text = genome.name
	_energy_cost_value_label.text = str(genome.get_energy_cost())
	
	for cell_type_panel:CellTypePanel in _cell_type_container.get_children():
		_cell_type_container.remove_child(cell_type_panel)
		cell_type_panel.queue_free()
		
	for cell_type in genome.cell_types:
		var cell_type_panel:CellTypePanel = CELL_TYPE_PANEL.instantiate()
		_cell_type_container.add_child(cell_type_panel)
		cell_type_panel.show_cell_type(cell_type)
		
	var selected_index := -1
	for index in range(_appearance_set_option_button.item_count):
		var selected_text := _appearance_set_option_button.get_item_text(index)
		if selected_text == genome.appearance_set.name:
			selected_index = index
			break
	_appearance_set_option_button.select(selected_index)
	
func _on_current_level_modified() -> void:
	_energy_cost_value_label.text = str(genome.get_energy_cost())
	
func _on_add_cell_type_button_pressed() -> void:
	var cell_type := genome.add_cell_type()
	var cell_type_panel:CellTypePanel = CELL_TYPE_PANEL.instantiate()
	_cell_type_container.add_child(cell_type_panel)
	cell_type_panel.show_cell_type(cell_type)
	CellTypePanel.signals.cell_type_selected.emit(cell_type)
	Level.current.modified()

func _on_genome_name_text_changed(new_text:String) -> void:
	genome.name = new_text
	Level.current.modified()

func _on_remove_genome_button_pressed() -> void:
	for index in Level.current.content.get_all_indexes():
		var initial_hex_content := Level.current.get_hex_content(index)
		if initial_hex_content.cell_type.genome == genome:
			MainScene.signals.set_target_highlight.emit(index, MainScene.HexColor.BadTarget)
	_confirm_remove_genome_name.text = '"%s"' % [genome.name]
	_confirm_remove_genome_popup.reset_size()
	_confirm_remove_genome_popup.popup(
		Rect2(
			_confirm_remove_genome_popup.get_parent().global_position - 
				Vector2(_confirm_remove_genome_popup.size.x + 12, 0), 
			_confirm_remove_genome_popup.size
		)
	)
	
func _on_cancel_remove_genome_button_pressed() -> void:
	_confirm_remove_genome_popup.hide()
	
func _on_confirm_remove_genome_popup_popup_hide() -> void:
	for index in Level.current.content.get_all_indexes():
		var initial_hex_content := Level.current.get_hex_content(index)
		if initial_hex_content.cell_type.genome == genome:
			MainScene.signals.clear_target_highlight.emit(index)
	
func _on_confirm_remove_genome_button_pressed() -> void:
	_confirm_remove_genome_popup.hide()
	for index in Level.current.content.get_all_indexes():
		var initial_hex_content := Level.current.get_hex_content(index)
		if initial_hex_content.cell_type.genome == genome:
			Level.current.content.clear_content(index)
	Level.current.genomes.erase(genome)
	Level.current.modified()
	# deffered to avoid error: 
	#   E 0:00:09:420   _push_unhandled_input_internal: Condition "!is_inside_tree()" is true.
	#   <C++ Source>  scene/main/viewport.cpp:3338 @ _push_unhandled_input_internal()
	_remove_self.call_deferred() 
	
func _remove_self() -> void:
	get_parent().remove_child(self)
	queue_free()

func _on_appearance_set_option_button_item_selected(index:int) -> void:
	var selected_name = _appearance_set_option_button.get_item_text(index)
	var appearance_set = AppearanceSet.get_appearance_set(selected_name)
	genome.appearance_set = appearance_set
	Level.current.modified()
	show_genome(genome)
