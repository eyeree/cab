@tool
extends EditorPlugin

var cpm: ColorPaletteManager

func _enter_tree():
	cpm = preload("res://addons/color-palette/ColorPaletteManager.tscn").instantiate()
	cpm.undoredo = get_undo_redo()
	add_control_to_bottom_panel(cpm, "Color Palette")


func _exit_tree():
	remove_control_from_bottom_panel(cpm)
	cpm.free()
