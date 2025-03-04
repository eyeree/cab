@tool
class_name ScaleContainer extends Container

@export_range(0, 5, 0.1) var ui_scale := 1.0:
	set(value):
		ui_scale = value
		_scale_changed()

# Changes to oversampling while running corrupts the displayed fonts. Don't
# know why. Setting once at startup using  ScaleContaine.set_font_oversampling
# does seem to work fine however.
#@export var auto_update_font_oversampling := false		

func _ready() -> void:
	_scale_changed()
	
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN:
			var ui_scale_v := Vector2(ui_scale, ui_scale)
			var rect := Rect2(Vector2.ZERO, size)
			for child in get_children():
				if child is Control:
					child.position = Vector2.ZERO
					child.size = size / ui_scale
					child.scale = ui_scale_v
		
func _get_minimum_size() -> Vector2:
	var min_size := Vector2(0, 0)
	for child in get_children():
		if child is Control:
			var child_min_size:Vector2 = child.get_combined_minimum_size()
			min_size = min_size.max(child_min_size)
	min_size *= ui_scale
	return min_size

func _scale_changed() -> void:
	#if auto_update_font_oversampling and not Engine.is_editor_hint():
		#set_font_oversampling(max(1.0, ui_scale))
	update_minimum_size()

static func set_font_oversampling(value:float) -> void:
	var ts := TextServerManager.get_primary_interface()
	ts.font_set_global_oversampling(value)
