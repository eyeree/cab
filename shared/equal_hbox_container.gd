class_name EqualHBoxContainer extends HBoxContainer

func _ready() -> void:
	
	var max_min_size:float = 0
	
	for child in get_children():
		if child is Control:
			var min_size:Vector2 = child.get_minimum_size()
			if min_size.x > max_min_size:
				max_min_size = min_size.x
	
	for child in get_children():
		if child is Control:
			var min_size:Vector2 = child.get_minimum_size()
			min_size.x = max_min_size
			child.set_custom_minimum_size(min_size)
