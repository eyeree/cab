class_name CellTypePanel extends PanelContainer

@onready var _cell_type_name: LineEdit = %CellTypeName
@onready var _delete_cell_type_button: Button = %DeleteCellTypeButton
@onready var _cell_appearance_container: CellAppearanceContainer = %CellAppearanceContainer
@onready var _energy_cost_label: Label = %EnergyCostLabel
@onready var _appearance_drag_source: AppearanceDragSource = %AppearanceDragSource

var cell_type:CellType

class CellTypePanelSignals:
	@warning_ignore("unused_signal")
	signal cell_type_selected(cell_type:CellType)
	
static var signals := CellTypePanelSignals.new()

func _ready() -> void:
	_delete_cell_type_button.pressed.connect(_on_delete_cell_type_button_pressed)
	_cell_type_name.text_changed.connect(_on_cell_type_name_text_changed)
	_cell_type_name.focus_entered.connect(_on_cell_type_name_focus_entered)
	signals.cell_type_selected.connect(_on_cell_type_selected)

func show_cell_type(cell_type_:CellType) -> void:
	cell_type = cell_type_
	_cell_type_name.text = cell_type.name
	_energy_cost_label.text = str(cell_type.energy_cost)
	_cell_appearance_container.cell_type = cell_type
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
