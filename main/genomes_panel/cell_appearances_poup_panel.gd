class_name CellAppearancesPopupPanel extends PopupPanel

@onready var _appearances_container: VBoxContainer = %AppearancesContainer
const CELL_APPEARANCE_CONTAINER = preload("res://main/genomes_panel/cell_appearance_container.tscn")

@export var normal:StyleBox
@export var hover:StyleBox
@export var selected:StyleBox

signal appearance_index_selected(new_index:int)

func show_appearance_set(selected_index:int, appearance_set:AppearanceSet) -> void:
	
	for child in _appearances_container.get_children():
		_appearances_container.remove_child(child)
		child.queue_free()
		
	for index in range(appearance_set.cell_appearances.size()):
		
		var cell_appearance_packed_scene = appearance_set.cell_appearances[index]
		var cell_appearance_container:CellAppearanceContainer = CELL_APPEARANCE_CONTAINER.instantiate()
		cell_appearance_container.cell_appearance = cell_appearance_packed_scene.instantiate()

		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override('panel', selected if index == selected_index else normal)
		panel.add_child(cell_appearance_container)
		
		panel.mouse_entered.connect(func (): 
			panel.add_theme_stylebox_override('panel', hover))
		panel.mouse_exited.connect(func (): 
			panel.add_theme_stylebox_override('panel', 
				selected if index == selected_index else normal))
		panel.gui_input.connect(func (event:InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				appearance_index_selected.emit(index))
		
		_appearances_container.add_child(panel)

	#child_controls_changed()
	
	size = get_contents_minimum_size()
