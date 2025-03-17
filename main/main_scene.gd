class_name MainScene extends Node3D

@onready var _grid: HexGrid = %HexGrid
@onready var _cell_state_panel: CellStatePanel = %CellStatePanel
@onready var _control_panel: ControlPanel = %ControlPanel
@onready var _genes_panel: GenesPanel = %GenesPanel
@onready var _level_panel: LevelPanel = %LevelPanel
@onready var _genomes_panel: GenomesPanel = %GenomesPanel
@onready var _grid_viewport_container: GridViewportContainer = %GridViewportContainer

@onready var _grid_overlay_panel: Panel = %GridOverlayPanel
@onready var _window_overlay_panel: Panel = %WindowOverlayPanel

@onready var _debug_panel: PanelContainer = %DebugPanel
@onready var _debug_hex_index: Label = %DebugHexIndex

@onready var _world: World = %World

const CURSOR_GRAB = preload("res://icon/cursor_grab.svg")
const CURSOR_POINT = preload("res://icon/cursor_point.svg")

var _load_needed:bool = true
var _load_start_time:int

var _selected_index := HexIndex.INVALID
var _hover_index := HexIndex.INVALID
var _shown_index := HexIndex.INVALID
var _selected_cell_type:CellType = null

var _is_build_mode:bool 

enum HexColor {
	Hover = 0,
	Selected = 1,
	BadTarget = 2,
	NeturalTarget = 3,
	GoodTarget = 4
}

func _ready() -> void:
	
	var ts := TextServerManager.get_primary_interface()
	ts.font_set_global_oversampling(10)
		
	Input.set_custom_mouse_cursor(preload("res://icon/mouse_drag_enabled.svg"), Input.CURSOR_DRAG, Vector2(16, 16))
	Input.set_custom_mouse_cursor(preload("res://icon/mouse_drag_good.svg"), Input.CURSOR_CAN_DROP, Vector2(16, 16))
	Input.set_custom_mouse_cursor(preload("res://icon/mouse_drag_bad.svg"), Input.CURSOR_FORBIDDEN, Vector2(16, 16))
	Input.set_custom_mouse_cursor(preload("res://icon/mouse_text.svg"), Input.CURSOR_IBEAM, Vector2(16, 16))
	
	ScaleContainer.set_font_oversampling(3)
	
	_control_panel.current_step_changed.connect(_on_current_step_changed)
	_control_panel.ring_count_changed.connect(_on_ring_count_changed)
	_control_panel.step_count_changed.connect(_on_step_count_changed)
	_control_panel.run_speed_changed.connect(_run_speed_changed)
	
	_grid.mouse_entered_hex.connect(_on_mouse_entered_hex)
	_grid.mouse_exited_hex.connect(_on_mouse_exited_hex)
	_grid.hex_selected.connect(_on_hex_selected)
	
	_world.load_started.connect(_load_started)
	_world.load_progress.connect(_load_progress)
	_world.load_finished.connect(_load_finished)
	
	_level_panel.dialog_opened.connect(_show_window_overlay)
	_level_panel.dialog_closed.connect(_hide_window_overlay)
	_level_panel.level_changed.connect(_level_changed)
	
	GeneStatePanel.gene_signals.set_target_highlight.connect(_set_target_highlight)
	GeneStatePanel.gene_signals.clear_target_highlight.connect(_clear_target_highlight)
	
	CellTypePanel.signals.cell_type_selected.connect(_on_cell_type_selected)
	
	_control_panel.run_speed = _level_panel.state.run_speed
	
	_level_changed()
	
func _build_mode() -> void:
	
	_is_build_mode = true
	_grid_viewport_container.drag_enabled = true
	
	_cell_state_panel.visible = false
	_genomes_panel.visible = true
	_genes_panel.visible = true
	
	if _selected_index != HexIndex.INVALID:
		_grid.clear_hex_color(_selected_index)
		if _hover_index != HexIndex.INVALID:
			_grid.set_hex_color(_hover_index, HexColor.Hover)
			
	_update_grid_from_level()
	
func _view_mode() -> void:
	
	_is_build_mode = false
	_grid_viewport_container.drag_enabled = false
	
	_genomes_panel.visible = false
	_genes_panel.visible = false
	
	_grid.clear_all_hex_colors()

	if _selected_index != HexIndex.INVALID:
		_grid.set_hex_color(_selected_index, HexColor.Selected)
		_cell_state_panel.visible = true
	elif _hover_index != HexIndex.INVALID:
		_grid.set_hex_color(_hover_index, HexColor.Hover)
		_cell_state_panel.visible = true

	if _load_needed:
		_start_load()

func _run_speed_changed(value:float) -> void:
	_level_panel.state.run_speed = value
	_level_panel.state.save()
	
func _set_target_highlight(index:HexIndex, type:GeneStatePanel.TargetType) -> void:
	
	var hex_color:HexColor
	match type:
		GeneStatePanel.TargetType.Good:
			hex_color = HexColor.GoodTarget
		GeneStatePanel.TargetType.Netural:
			hex_color = HexColor.NeturalTarget
		GeneStatePanel.TargetType.Bad:
			hex_color = HexColor.BadTarget
		
	_grid.set_hex_color(index, hex_color)

func _clear_target_highlight(index:HexIndex) -> void:
	if _selected_index == index:
		_grid.set_hex_color(index, HexColor.Selected)
	else:
		_grid.clear_hex_color(index)
	
func _on_mouse_entered_hex(index:HexIndex):
	_debug_hex_index.text = str(index)
	_hover_index = index
	if _is_build_mode:
		_on_mouse_entered_hex_build(index)
	else:		
		_on_mouse_entered_hex_view(index)

func _on_mouse_entered_hex_build(index:HexIndex):
	var initial_hex_content := Level.current.get_hex_content(index)
	if initial_hex_content == null or initial_hex_content.cell_type != _selected_cell_type:
		_grid.set_hex_color(index, HexColor.Hover)
	if initial_hex_content != null:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		var cell_appearance:CellAppearance = _grid.get_hex_content(index)
		if not cell_appearance:
			prints("cell_appearance is null when initial_hex_content is not")
		else:
			cell_appearance.show_orientation(initial_hex_content.orientation)

func _on_mouse_entered_hex_view(index:HexIndex):
	if _selected_index == HexIndex.INVALID:
		_grid.set_hex_color(index, HexColor.Hover)
		_show_cell_state(index)

func _on_mouse_exited_hex(index:HexIndex):
	_hover_index = HexIndex.INVALID
	if _is_build_mode:
		_on_mouse_exited_hex_build(index)
	else:
		_on_mouse_exited_hex_view(index)
		
func _on_mouse_exited_hex_build(index:HexIndex):
	var initial_hex_content := Level.current.get_hex_content(index)
	if initial_hex_content != null and initial_hex_content.cell_type == _selected_cell_type:
		_grid.set_hex_color(index, HexColor.Selected)
	else:
		_grid.clear_hex_color(index)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	if initial_hex_content:
		var cell_appearance:CellAppearance = _grid.get_hex_content(index)
		cell_appearance.hide_orientation()

func _on_mouse_exited_hex_view(index:HexIndex):
	if _selected_index == HexIndex.INVALID:
		_grid.clear_hex_color(index)
		_hide_cell_state()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_END:
			if _hover_index != HexIndex.INVALID:
				var initial_hex_content := Level.current.get_hex_content(_hover_index)
				if initial_hex_content != null:
					Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			
func _on_hex_selected(index:HexIndex):
	if _is_build_mode:
		_on_hex_selected_build(index)
	else:
		_on_hex_selected_view(index)
		
func _on_hex_selected_build(index:HexIndex) -> void:
	var initial_hex_content := Level.current.get_hex_content(index)
	var cell_type:CellType = initial_hex_content.cell_type if initial_hex_content else null
	CellTypePanel.signals.cell_type_selected.emit(cell_type)
	
func _on_hex_selected_view(index:HexIndex) -> void:
	if _selected_index == index:
		_selected_index = HexIndex.INVALID
		_grid.set_hex_color(index, HexColor.Hover)
	elif index == HexIndex.INVALID:
		_grid.clear_hex_color(_selected_index)
		_selected_index = HexIndex.INVALID
		_hide_cell_state()
	else:
		_grid.clear_hex_color(_selected_index)
		_grid.set_hex_color(index, HexColor.Selected)
		_selected_index = index
		_show_cell_state(index)

func _show_cell_state(index:HexIndex):
	if _world.state:
		_shown_index = index
		_cell_state_panel.visible = true
		var cell_state := _world.state.get_history_entry(index, _control_panel.current_step)
		_cell_state_panel.show_cell_state(cell_state)
		
func _hide_cell_state() -> void:
	_shown_index = HexIndex.INVALID
	_cell_state_panel.visible = false
		
func _start_load() -> void:
	
	_control_panel.loaded_steps = 0
	_load_needed = false
	
	_load_start_time = Time.get_ticks_msec()
	
	var world_options = World.WorldOptions.new()
	world_options.level = Level.current
	_world.load(world_options)
		
func _load_started() -> void:
	pass

func _load_progress(loaded_steps:int) -> void:
	_control_panel.loaded_steps = loaded_steps
	if _control_panel.current_step <= loaded_steps:
		_grid_overlay_panel.visible = false
		#_update_grid_from_world()
	
func _load_finished() -> void:
	var load_end_time := Time.get_ticks_msec()
	prints('Load time ms:', load_end_time - _load_start_time)
	if _load_needed:
		_control_panel.loaded_steps = 0
		
func _on_current_step_changed(current_step:int) -> void:
	
	if current_step == 0:
		_build_mode()
	else:
		_view_mode()
	
	if _is_build_mode:
		pass
	else:
		_on_current_step_changed_view(current_step)
		
func _on_current_step_changed_view(current_step:int) -> void:
	if current_step <= _control_panel.loaded_steps:
		_grid_overlay_panel.visible = false
		_update_grid_from_world()
	elif current_step > _control_panel.loaded_steps + 1:
		_grid_overlay_panel.visible = true

func _update_grid_from_world():
	var current_step := _control_panel.current_step
	for index:HexIndex in HexIndex.CENTER.spiral(_grid.rings):
		var cell_state:CellState = _world.state.get_history_entry(index, current_step)
		var cell_type:CellType = cell_state.cell.cell_type # if cell_state and cell_state.cell else null
		_set_cell_appearance(index, cell_type)
		_set_cell_state(index, cell_state)
	
func _update_grid_from_level():
	_grid.clear_all_hex_colors()
	for index:HexIndex in HexIndex.CENTER.spiral(_grid.rings):
		var initial_hex_content := Level.current.get_hex_content(index)
		var cell_type:CellType = initial_hex_content.cell_type if initial_hex_content else null
		var cell_appearance := _set_cell_appearance(index, cell_type)
		if cell_appearance and index == _hover_index:
			cell_appearance.show_orientation(initial_hex_content.orientation)
		if _selected_cell_type and cell_type == _selected_cell_type:
			_grid.set_hex_color(index, HexColor.Selected)
				
func _set_cell_appearance(index:HexIndex, cell_type:CellType) -> CellAppearance:
	
	var current_cell_appearance:CellAppearance = _grid.get_hex_content(index)
	
	if cell_type and cell_type.is_correct_cell_appearance(current_cell_appearance):
		return
	
	var new_cell_appearance:CellAppearance = cell_type.instantiate_cell_appearance() \
		if cell_type else null
		
	_grid.set_hex_content(index, new_cell_appearance)
	
	if current_cell_appearance: 
		current_cell_appearance.queue_free()
		
	return new_cell_appearance
	
func _set_cell_state(index:HexIndex, cell_state:CellState):
	var cell_appearance:CellAppearance = _grid.get_hex_content(index)
	if cell_appearance:
		cell_appearance.set_state(cell_state)
	if index == _shown_index:
		_show_cell_state(index)

func _process(_delta:float) -> void:
	if Input.is_action_just_pressed("ToggleDebugPanel"):
		_debug_panel.visible = not _debug_panel.visible
	if Input.is_action_just_pressed("RotateOrientationClockwise") or Input.is_action_just_pressed("RotateOrientationCounterClockwise"):
		prints(Input.is_action_just_pressed("GridCameraZoomIn"), Input.is_action_just_pressed("GridCameraZoomOut"))
		if not Input.is_action_just_pressed("GridCameraZoomIn") and not Input.is_action_just_pressed("GridCameraZoomOut"):
			if _hover_index != HexIndex.INVALID:
				var initial_hex_content := Level.current.get_hex_content(_hover_index)
				if initial_hex_content:
					initial_hex_content.orientation = \
						HexIndex.rotate_direction_clockwise(initial_hex_content.orientation) \
							if Input.is_action_just_pressed("RotateOrientationClockwise") \
							else HexIndex.rotate_direction_counter_clockwise(initial_hex_content.orientation)
					Level.current.modified()
					var cell_appearance:CellAppearance = _grid.get_hex_content(_hover_index)
					cell_appearance.show_orientation(initial_hex_content.orientation)

func _on_step_count_changed(step_count:int) -> void:
	Level.current.steps = step_count
	Level.current.modified()
	_reset_load()
	
func _on_ring_count_changed(ring_count:int) -> void:
	Level.current.rings = ring_count
	Level.current.modified()
	_grid.rings = ring_count
	_reset_load()
	_update_grid_from_level()
	
func _reset_load():
	_world.stop_loading()
	_load_needed = true
	_control_panel.loaded_steps = 0
		
func _show_window_overlay():
	_window_overlay_panel.visible = true
	
func _hide_window_overlay():
	_window_overlay_panel.visible = false

func _level_changed() -> void:
	Level.current.level_modified.connect(_on_level_modified)
	_control_panel.reset(Level.current.rings, Level.current.steps)
	_grid.rings = Level.current.rings
	_selected_index = HexIndex.INVALID
	_reset_load()
	_genomes_panel.show_genomes()
	_build_mode()
	
func _on_level_modified() -> void:
	_reset_load()
	_update_grid_from_level()

func _on_cell_type_selected(cell_type:CellType) -> void:
	_genes_panel.show_cell_type(cell_type)
	_selected_cell_type = cell_type
	_update_grid_from_level()
