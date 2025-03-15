class_name CellTypePanel extends PanelContainer

@onready var _cell_type_name: LineEdit = %CellTypeName
@onready var _delete_cell_type_button: Button = %DeleteCellTypeButton
@onready var _cell_appearance_container: CellAppearanceContainer = %CellAppearanceContainer
@onready var _energy_cost_label: Label = %EnergyCostLabel
@onready var _appearance_drag_source: AppearanceDragSource = %AppearanceDragSource
@onready var _pick_cell_appearance_button: TextureButton = %PickCellAppearanceButton
@onready var _cell_appearances_popup_panel: CellAppearancesPopupPanel = %CellAppearancesPopupPanel

var cell_type:CellType

class CellTypePanelSignals:
	@warning_ignore("unused_signal")
	signal cell_type_selected(cell_type:CellType)
	
static var signals := CellTypePanelSignals.new()

func _ready() -> void:
	_delete_cell_type_button.pressed.connect(_on_delete_cell_type_button_pressed)
	_cell_type_name.text_changed.connect(_on_cell_type_name_text_changed)
	_cell_type_name.focus_entered.connect(_on_cell_type_name_focus_entered)
	_pick_cell_appearance_button.pressed.connect(_on_pick_cell_appearance_button_pressed)
	signals.cell_type_selected.connect(_on_cell_type_selected)
	_cell_appearances_popup_panel.visible = false
	_cell_appearances_popup_panel.appearance_index_selected.connect(_on_cell_appearances_popup_panel_appearance_index_selected)

func show_cell_type(cell_type_:CellType) -> void:
	cell_type = cell_type_
	_cell_type_name.text = cell_type.name
	_energy_cost_label.text = str(cell_type.energy_cost)
	_cell_appearance_container.cell_appearance = cell_type.instantiate_cell_appearance()
	_appearance_drag_source.cell_type = cell_type

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			signals.cell_type_selected.emit(cell_type)

func _on_cell_type_name_text_changed(new_text:String) -> void:
	cell_type.name = new_text
	Level.current.modified()
	
func _on_cell_type_name_focus_entered() -> void:
	if not _is_selected:
		signals.cell_type_selected.emit(cell_type)
	
func _on_cell_type_selected(selected_cell_type:CellType) -> void:
	if selected_cell_type == cell_type:
		theme_type_variation = "CellTypePanelSelected"
	else:
		theme_type_variation = "CellTypePanel"
		if _cell_type_name.has_focus():
			_cell_type_name.release_focus()
		
var _is_selected:bool:
	get:
		return theme_type_variation == "CellTypePanelSelected"
		
func _on_delete_cell_type_button_pressed() -> void:
	cell_type.genome.remove_cell_type(cell_type)
	Level.current.modified()
	get_parent().remove_child(self)	
	queue_free()
	
func _exit_tree() -> void:
	if _is_selected:
		signals.cell_type_selected.emit(null)

func _on_pick_cell_appearance_button_pressed() -> void:
	signals.cell_type_selected.emit(cell_type)
	_cell_appearances_popup_panel.visible = not _cell_appearances_popup_panel.visible
	if _cell_appearances_popup_panel.visible:
		var parent = _cell_appearances_popup_panel.get_parent()
		_cell_appearances_popup_panel.position = parent.global_position + Vector2(0, parent.size.y - 1)
		_cell_appearances_popup_panel.show_appearance_set(cell_type.cell_appearance_index, cell_type.genome.appearance_set)

func _on_cell_appearances_popup_panel_appearance_index_selected(new_index:int) -> void:
	cell_type.cell_appearance_index = new_index
	_cell_appearance_container.cell_appearance = cell_type.instantiate_cell_appearance()
	Level.current.modified()
	_cell_appearances_popup_panel.visible = false
