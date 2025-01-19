class_name TemplateGridContaier extends GridContainer

var template_children:Array[Control] = []
var header:bool

func _ready() -> void:
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	var children = get_children()
	if children.size() == columns:
		header = false
		template_children.assign(children)
	elif children.size() == columns * 2:
		header = true
		template_children.assign(children.slice(columns))
	else:	
		push_error('Expected number of children to match number of columns, but found %d children and %d columns' % [template_children.size(), columns])
		
	for child in template_children:
		child.visible = false
		
func clear() -> void:
	for child in get_children().slice(columns * 2 if header else columns):
		remove_child(child)
		child.queue_free()
		
func add_row() -> Array:
	var row_children:Array = template_children.map(
		func (template_child:Control):
			return template_child.duplicate())
	for row_child:Control in row_children:
		add_child(row_child)
		row_child.visible = true
	return row_children

signal mouse_entered_row(row:int)
signal mouse_exited_row(row:int)
var current_mouse_row:int = -1
var mouse_over:bool = false

func _on_mouse_entered() -> void:
	#prints('mouse entered')
	mouse_over = true

func _on_mouse_exited() -> void:
	#prints('mouse exited')
	mouse_over = false
	if current_mouse_row != -1:
		#prints('--> exited row', current_mouse_row)
		mouse_exited_row.emit(current_mouse_row)
		current_mouse_row = -1	
	
func _input(event: InputEvent) -> void:
	var v_separation_half:float = get_theme_constant("v_separation") / 2.0
	if event is InputEventMouseMotion and mouse_over:
		var mouse_position:Vector2 = event.global_position - global_position
		#prints("mouse over", mouse_position)
		var row_bottom:float = 0.0
		var row_height:float = 0.0
		var row_child_count:int = 0
		var row_index:int = 0
		for child:Control in get_children():
			if child.visible and child.size.y > row_height:
				row_height = child.size.y
				#prints('    row_height changed', row_height)
			row_child_count += 1
			#prints('  processed child', current_mouse_row, row_index, row_child_count, row_height, row_bottom, mouse_position.y, child)
			if row_child_count == columns:
				if row_height > 0:
					row_bottom += row_height + v_separation_half
					#prints('    row_bottom', row_index, row_bottom, mouse_position.x)
					if mouse_position.y <= row_bottom:
						break
					row_bottom += v_separation_half
				#prints("row_index", row_height, row_index, '->', row_index + 1)
				row_index += 1
				row_height = 0
				row_child_count = 0
				
		row_index -=  2 if header else 1
		if row_index != current_mouse_row and current_mouse_row != -1:
			#prints('--> exited row', current_mouse_row)
			mouse_exited_row.emit(current_mouse_row)
			current_mouse_row = -1
		if row_index != current_mouse_row and row_index >= 0:
			current_mouse_row = row_index
			#prints('--> entered row', current_mouse_row)
			mouse_entered_row.emit(current_mouse_row)
