@tool
class_name LabelStyle extends StyleNode


@export var font_color:Color = Color.BLACK:
	set(value):
		font_color = value
		_style_modified()

func _init() -> void:
	super._init([Label])
	
func _update_target(target:Control) -> void:
	target.add_theme_color_override("font_color", font_color)
