class_name CellTypePanel extends PanelContainer

@onready var _cell_appearance_viewport: SubViewport = %CellAppearance
@onready var _cell_type_name: Label = %CellTypeName
@onready var _delete_cell_type_button: Button = %DeleteCellTypeButton

var cell_type:CellType
var selected:bool = false:
	set(value):
		selected = value
		if selected:
			theme_type_variation = "CellTypePanelSelected"
		else:
			theme_type_variation = "CellTypePanel"

signal delete_cell_type(cell_type:CellType)
signal cell_type_clicked(cell_type:CellType)

func _ready() -> void:
	_delete_cell_type_button.pressed.connect(func (): delete_cell_type.emit(cell_type))

func show_cell_type(cell_type_:CellType) -> void:
	cell_type = cell_type_
	_cell_type_name.text = "%s (%d)" % [cell_type.name, cell_type.energy_cost]
	var cell_appearance:CellAppearance = cell_type.instantiate_cell_appearance()
	_cell_appearance_viewport.add_child(cell_appearance)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			cell_type_clicked.emit(cell_type)
