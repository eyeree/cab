class_name MainScene extends Node

@onready var _grid: HexGrid = %HexGrid
@onready var _cell_state_panel: CellStatePanel = %CellStatePanel
@onready var _control_panel: ControlPanel = %ControlPanel
@onready var _cell_info_panel: PanelContainer = %CellInfoPanel
@onready var _cell_config_panel: PanelContainer = %CellConfigPanel
@onready var _level_panel: LevelPanel = %LevelPanel

@onready var _grid_overlay_panel: Panel = %GridOverlayPanel
@onready var _window_overlay_panel: Panel = %WindowOverlayPanel

@onready var _debug_panel: PanelContainer = %DebugPanel
@onready var _debug_hex_index: Label = %DebugHexIndex

@onready var _world: World = %World

var _load_needed:bool = true

var _selected_index := HexIndex.INVALID
var _shown_index := HexIndex.INVALID

enum HexColor {
	Hover = 0,
	Selected = 1,
	BadTarget = 2,
	NeturalTarget = 3,
	GoodTarget = 4
}

const HEX_LINE_COLORS:Array[Color] = [
	DefaultTheme.GRID_HOVER_LINE_COLOR, 
	DefaultTheme.GRID_SELECTED_LINE_COLOR, 
	DefaultTheme.GRID_BAD_TARGET_LINE_COLOR, 
	DefaultTheme.GRID_NETURAL_TARGET_LINE_COLOR, 
	DefaultTheme.GRID_GOOD_TARGET_LINE_COLOR
]

const HEX_FILL_COLORS:Array[Color] = [
	DefaultTheme.GRID_HOVER_FILL_COLOR, 
	DefaultTheme.GRID_SELECTED_FILL_COLOR, 
	DefaultTheme.GRID_BAD_TARGET_FILL_COLOR, 
	DefaultTheme.GRID_NETURAL_TARGET_FILL_COLOR, 
	DefaultTheme.GRID_GOOD_TARGET_FILL_COLOR
]

func _ready() -> void:

	_control_panel.current_step_changed.connect(_on_current_step_changed)
	_control_panel.ring_count_changed.connect(_on_ring_count_changed)
	_control_panel.step_count_changed.connect(_on_step_count_changed)
	
	_grid.mouse_entered_hex.connect(_on_mouse_entered_hex)
	_grid.mouse_exited_hex.connect(_on_mouse_exited_hex)
	_grid.hex_selected.connect(_on_hex_selected)
	_grid.default_line_color = DefaultTheme.GRID_DEFAULT_LINE_COLOR
	_grid.default_background_color = DefaultTheme.GRID_DEFAULT_FILL_COLOR
	_grid.hex_line_colors = HEX_LINE_COLORS
	_grid.hex_background_colors = HEX_FILL_COLORS
	
	_world.load_started.connect(_load_started)
	_world.load_progress.connect(_load_progress)
	_world.load_finished.connect(_load_finished)
	
	_level_panel.dialog_opened.connect(_show_window_overlay)
	_level_panel.dialog_closed.connect(_hide_window_overlay)
	_level_panel.level_changed.connect(_level_changed)
	
	GeneStatePanel.gene_signals.set_target_highlight.connect(_set_target_highlight)
	GeneStatePanel.gene_signals.clear_target_highlight.connect(_clear_target_highlight)
	
	_level_changed()

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
	if _selected_index == HexIndex.INVALID:
		_grid.set_hex_color(index, HexColor.Hover)
		_show_cell_info(index)
	_debug_hex_index.text = str(index)

func _on_mouse_exited_hex(index:HexIndex):
	if _selected_index == HexIndex.INVALID:
		_grid.clear_hex_color(index)
		_hide_cell_info()

func _on_hex_selected(index:HexIndex):
	if _selected_index == index:
		_selected_index = HexIndex.INVALID
		_grid.set_hex_color(index, HexColor.Hover)
		_hide_cell_info()
	elif index == HexIndex.INVALID:
		_grid.clear_hex_color(_selected_index)
		_selected_index = HexIndex.INVALID
		_hide_cell_info()
	else:
		_grid.clear_hex_color(_selected_index)
		_grid.set_hex_color(index, HexColor.Selected)
		_selected_index = index
		_show_cell_info(index)

func _show_cell_info(index:HexIndex) -> void:
	_shown_index = index
	_cell_info_panel.visible = true
	if _control_panel.current_step == 0:
		_cell_state_panel.visible = false
		_cell_config_panel.visible = true
		_show_cell_config(index)
	else:
		_cell_state_panel.visible = true
		_cell_config_panel.visible = false
		_show_cell_state(index)
		
func _show_cell_state(index:HexIndex):
	var cell_state := _world.state.get_history_entry(index, _control_panel.current_step)
	_cell_state_panel.show_cell_state(cell_state)
		
func _show_cell_config(_index:HexIndex):
	pass

func _hide_cell_info() -> void:
	_cell_info_panel.visible = false
		
func _start_load() -> void:
	
	_control_panel.loaded_steps = 0
	_load_needed = false
	
	var world_options = World.WorldOptions.new()
	world_options.rings = _level_panel.level.rings
	world_options.steps = _level_panel.level.steps
	world_options.initial_content = _level_panel.level.content
	_world.load(world_options)
		
func _load_started() -> void:
	pass

func _load_progress(loaded_steps:int) -> void:
	var was_waiting = _control_panel.current_step > _control_panel.loaded_steps \
		and _control_panel.current_step <= loaded_steps
	_control_panel.loaded_steps = loaded_steps
	if was_waiting:
		_grid_overlay_panel.visible = false
		_update_grid()
	
func _load_finished() -> void:
	if _load_needed:
		_control_panel.loaded_steps = 0
		
func _on_current_step_changed(current_step:int) -> void:
	if current_step > 0 and _load_needed:
		_start_load()
	if current_step <= _control_panel.loaded_steps:
		_update_grid()	

func _update_grid() -> void:
	if _control_panel.current_step == 0:
		_update_grid_from_level()
	else:
		_update_grid_from_world()

func _update_grid_from_world():
	var current_step := _control_panel.current_step
	for index:HexIndex in HexIndex.CENTER.spiral(_grid.rings):
		var cell_state:CellState = _world.state.get_history_entry(index, current_step)
		var cell_type:CellType = cell_state.cell.cell_type # if cell_state and cell_state.cell else null
		_set_cell_appearance(index, cell_type)
		_set_cell_state(index, cell_state)
	
func _update_grid_from_level():
	for index:HexIndex in HexIndex.CENTER.spiral(_grid.rings):
		var cell_type:CellType = _level_panel.level.content.get_content(index)
		_set_cell_appearance(index, cell_type)

func _set_cell_appearance(index:HexIndex, cell_type:CellType):
	
	var current_cell_appearance:CellAppearance = _grid.get_hex_content(index)
	
	if current_cell_appearance and current_cell_appearance.cell_type == cell_type:
		return
		
	var new_cell_appearance:CellAppearance = cell_type.instantiate_cell_appearance() \
		if cell_type else null
		
	_grid.set_hex_content(index, new_cell_appearance)
	
	if current_cell_appearance: 
		current_cell_appearance.queue_free()
	
func _set_cell_state(index:HexIndex, cell_state:CellState):
	var cell_appearance:CellAppearance = _grid.get_hex_content(index)
	if cell_appearance:
		cell_appearance.set_state(cell_state)
	if index == _shown_index:
		_show_cell_info(index)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ToggleDebugPanel"):
		_debug_panel.visible = not _debug_panel.visible

func _on_step_count_changed(step_count:int) -> void:
	_level_panel.level.steps = step_count
	_level_panel.level.signals.level_modified.emit()
	_reset_load()
	
func _on_ring_count_changed(ring_count:int) -> void:
	_level_panel.level.rings = ring_count
	_level_panel.level.signals.level_modified.emit()
	_grid.rings = ring_count
	_reset_load()
	_update_grid()
	
func _reset_load():
	_world.stop_loading()
	_load_needed = true
	_control_panel.loaded_steps = 0
		
func _show_window_overlay():
	_window_overlay_panel.visible = true
	
func _hide_window_overlay():
	_window_overlay_panel.visible = false

func _level_changed() -> void:
	var level := _level_panel.level
	_control_panel.reset(level.rings, level.steps)
	_grid.rings = level.rings
	_on_hex_selected(HexIndex.INVALID)
	_reset_load()
	_update_grid()
