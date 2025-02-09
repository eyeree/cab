class_name BattleMode extends Node

@onready var _first_step_button: Button = %FirstStepButton
@onready var _previous_step_button: Button = %PreviousStepButton
@onready var _run_button: Button = %RunButton
@onready var _pause_button: Button = %PauseButton
@onready var _next_step_button: Button = %NextStepButton
@onready var _last_step_button: Button = %LastStepButton
@onready var _current_step_slider: HSlider = %CurrentStepSlider
@onready var _load_progress_bar: ProgressBar = %LoadProgressBar
@onready var _run_speed_slider: HSlider = %RunSpeedSlider
@onready var _grid: Grid = %Grid
@onready var _cell_details_panel: CellDetailsPanel = %CellDetailsPanel
@onready var _overlay_panel: Panel = %OverlayPanel
@onready var _current_step_value: Label = %CurrentStepValue
@onready var _num_steps_value: Label = %NumStepsValue
@onready var _overlay_label: Label = %OverlayLabel

@onready var _debug_panel: PanelContainer = %DebugPanel
@onready var _debug_hex_index: Label = %DebugHexIndex

const _min_run_run_steps_per_second := 1.0
const _max_run_run_steps_per_second := 500.0
const _default_run_speed_percent := 0.5
@export var _run_speed_curve:Curve

var _is_running:bool = false
var _run_steps_per_second:float

var _is_loading:bool = false

var _world:World = null
var _world_state:WorldState = null

var _selected_index:HexIndex = HexIndex.INVALID
var _mouse_index:HexIndex = HexIndex.INVALID
var _index_shown:HexIndex = HexIndex.INVALID

var _num_steps:int
var _current_step:int
var _displayed_step:int
var _loaded_steps:int

var _step_delta:float

var _load_thread:Thread = null
var _stop_loading:bool = false

func _ready() -> void:
	
	_first_step_button.pressed.connect(_first_step)
	_previous_step_button.pressed.connect(_previous_step)
	_run_button.pressed.connect(_run)
	_pause_button.pressed.connect(_pause)
	_next_step_button.pressed.connect(_next_step)
	_last_step_button.pressed.connect(_last_step)
	_current_step_slider.value_changed.connect(_on_current_step_changed)
	
	_run_speed_slider.value_changed.connect(_on_run_speed_changed)
	_run_speed_slider.value = _default_run_speed_percent
	_on_run_speed_changed(_run_speed_slider.value)
	
	_grid.mouse_entered_hex.connect(_on_mouse_entered_hex)
	_grid.mouse_exited_hex.connect(_on_mouse_exited_hex)
	_grid.hex_selected.connect(_on_hex_selected)
	
	GeneDetailUI.gene_signals.highlight_cell.connect(_highlight_cell)

	battle()
	
func _process(delta: float) -> void:
	if _is_loading:	_load_process()
	if _is_running: _run_process(delta)
	
func _highlight_cell(index:HexIndex) -> void:
	_grid.set_selected_index(index)
	
func _on_mouse_entered_hex(index:HexIndex):
	_grid.set_selected_index(index)
	_show_cell(index)
	_mouse_index = index
	_debug_hex_index.text = str(_mouse_index)

func _on_mouse_exited_hex(_index:HexIndex):
	_show_selected_cell()

func _on_hex_selected(index:HexIndex):
	_selected_index = index
	_grid.set_highlighted_indexes([_selected_index])
	_show_selected_cell()

func _show_cell(index:HexIndex) -> void:
	_index_shown = index
	_update_shown_cell()
	
func _update_shown_cell() -> void:
	if _world_state == null: return
	var cell_state:CellState = _world_state.get_history_entry(_index_shown, _current_step)
	_cell_details_panel.show_cell_state(cell_state)

func _show_selected_cell() -> void:
	_grid.clear_selected_index()
	_mouse_index = HexIndex.INVALID
	if _selected_index == HexIndex.INVALID:
		_cell_details_panel.hide_panel()
	else:
		_show_cell(_selected_index)

class BattleOptions extends RefCounted:
	var rings:int = 10
	var steps:int = 5000
	var initial_content:HexStore
	
func battle(options:BattleOptions = BattleOptions.new()) -> void:
	
	_grid.clear_all_hex_content()
	
	_num_steps = options.steps
	_current_step = -1
	_displayed_step = -1
	_loaded_steps = -1

	_num_steps_value.text = str(_num_steps)
	_current_step_value.text = str(_current_step)
	
	_current_step_slider.max_value = _num_steps
	_current_step_slider.min_value = 0
	_current_step_slider.set_value_no_signal(0)
	_current_step_slider.editable = false
	
	_load_progress_bar.min_value = 0
	_load_progress_bar.max_value = _num_steps
	_load_progress_bar.value = 0
	
	_first_step_button.disabled = true
	_previous_step_button.disabled = true
	_run_button.disabled = true
	_pause_button.disabled = true
	_next_step_button.disabled = true
	_last_step_button.disabled = true
	
	if OS.has_feature('nothreads'):
		
		_load(options)
		
	else:
		
		if _load_thread:
			_stop_loading = true
			_load_thread.wait_to_finish()
			_load_thread = null
			_stop_loading = false
			
		_load_thread = Thread.new()
		_load_thread.start(_load.bind(options))
		
	#_countdown()
	_current_step_slider.editable = true
		
func _exit_tree() -> void:
	if _load_thread and _load_thread.is_alive():
		_stop_loading = true
		_load_thread.wait_to_finish()
		
func _load(battle_options:BattleOptions) -> void:
	
	battle_options.rings = _grid.rings # FIX
	battle_options.initial_content = _get_initial_content() # FIX
	
	_world_state = WorldState.new(battle_options.rings, battle_options.steps)
	
	var world_options = World.WorldOptions.new()
	world_options.rings = battle_options.rings
	world_options.initial_content = battle_options.initial_content
	world_options.world_state = _world_state
	_world = World.new(world_options)
	
	if OS.has_feature('nothreads'):
		
		_is_loading = true
	
	else:
		_load_started.call_deferred()
		for step_number in range(1, _num_steps + 1):
			var start_ms:int = Time.get_ticks_msec()
			_world.step(step_number)
			var end_ms:int = Time.get_ticks_msec()
			_load_progress.call_deferred(step_number, end_ms - start_ms)
			if _stop_loading: break
		_load_finished.call_deferred()
		
func _load_process() -> void:
	if _loaded_steps == 0:
		_load_started()
	var total_ms:int = 0
	while total_ms < 32:
		var step_number:int = _loaded_steps + 1
		var start_ms:int = Time.get_ticks_msec()
		_world.step(step_number)
		var end_ms:int = Time.get_ticks_msec()
		var elapsed_ms:int = end_ms - start_ms
		total_ms += elapsed_ms
		_load_progress(step_number, elapsed_ms)
		if _loaded_steps == _num_steps:
			_is_loading = false
			_load_finished()
			break

func _load_started() -> void:
	_loaded_steps = 0
	_set_step(0)

func _load_progress(steps_done:int, _ms_per_step:float) -> void:
	
	#if steps_done > 100: return
	
	var was_waiting = _current_step > _loaded_steps and _current_step <= steps_done
	_loaded_steps = steps_done
	_load_progress_bar.value = _loaded_steps
	if was_waiting:
		_overlay_panel.visible = false
		_update_grid()
	
func _load_finished() -> void:
	pass
	
func _countdown() -> void:
	_overlay_panel.visible = true
	_overlay_label.text = '3'
	await get_tree().create_timer(1).timeout
	_overlay_label.text = '2'
	await get_tree().create_timer(1).timeout
	_overlay_label.text = '1'
	await get_tree().create_timer(1).timeout
	_overlay_panel.visible = false
	_current_step_slider.editable = true
	_run()
	
func _get_initial_content() -> HexStore:
	
	var genome1 = Genome.new()
	genome1.name = "Genome1"
	genome1.appearance_set = preload("res://appearance/simple_a/simple_a_appearance_set.tres")
	genome1.add_gene(GenerateEnergyGene)
	genome1.add_gene(RepairDamageGene)
	genome1.add_gene(ProduceCellGene)
	
	var cell_type_1a = genome1.add_cell_type()
	cell_type_1a.name = '1A'
	cell_type_1a.cell_appearance = genome1.appearance_set.get_cell_appearance_by_name('simple_a_cell_a')
	cell_type_1a.add_gene(GenerateEnergyGene)
	cell_type_1a.add_gene(RepairDamageGene)
	cell_type_1a.add_gene(ProduceCellGene)

	var genome2 = Genome.new()
	genome2.name = "Genome2"
	genome2.appearance_set = preload("res://appearance/simple_b/simple_b_appearance_set.tres")
	genome2.add_gene(GenerateEnergyGene)
	genome2.add_gene(RepairDamageGene)
	genome2.add_gene(ProduceCellGene)

	var cell_type_2a = genome2.add_cell_type()
	cell_type_2a.name = '2A'
	cell_type_2a.cell_appearance = genome2.appearance_set.get_cell_appearance_by_name('simple_b_cell_b')
	cell_type_2a.add_gene(GenerateEnergyGene)
	cell_type_2a.add_gene(RepairDamageGene)
	cell_type_2a.add_gene(ProduceCellGene)

	var initial_content:HexStore = HexStore.new()	
	
	initial_content.set_content(HexIndex.CENTER, cell_type_1a)
	#initial_content.set_content(HexIndex.from(-3, 0, 3), cell_type_1a)
	#initial_content.set_content(HexIndex.from(2, 2, -4), cell_type_2a)
	#initial_content.set_content(HexIndex.from(4, -2, -2), cell_type_2a)

	return initial_content
	
func _on_current_step_changed(value) -> void:
	_set_step(value)
	
func _first_step() -> void:
	_set_step(0)

func _previous_step() -> void:
	_set_step(_current_step - 1)
	
func _run() -> void:
	_is_running = true
	_step_delta = 0.0
	_update_ui()

func _pause() -> void:
	_is_running = false
	_update_ui()
	
func _next_step() -> void:
	_set_step(_current_step + 1)

func _last_step() -> void:
	_set_step(_num_steps)

func _on_run_speed_changed(value:float) -> void:
	_run_steps_per_second = remap(
		_run_speed_curve.sample(value), 
		0.0, 
		1.0,
		_min_run_run_steps_per_second, 
		_max_run_run_steps_per_second)
	
func _set_step(step_number:int) -> void:
	
	if step_number < 0:
		step_number = 0
	
	if step_number > _num_steps:
		step_number = _num_steps
		
	if _current_step == step_number:
		return
		
	_current_step = step_number
	
	if _current_step == _num_steps:
		_is_running = false
	
	_update_ui()
	
	if _current_step > _loaded_steps:
		_overlay_label.text = "Loading..."
		_overlay_panel.visible = true
	else:
		_overlay_panel.visible = false
		_update_grid()

func _update_ui() -> void:
	_first_step_button.disabled = _current_step == 0
	_previous_step_button.disabled = _current_step == 0 or _is_running
	_run_button.disabled = _current_step == _num_steps or _is_running
	_pause_button.disabled = not _is_running
	_next_step_button.disabled = _current_step == _num_steps or _is_running
	_last_step_button.disabled = _current_step == _num_steps
	_current_step_slider.set_value_no_signal(_current_step)
	_current_step_value.text = str(_current_step)
		
func _update_grid() -> void:
	for index:HexIndex in HexIndex.CENTER.spiral(_grid.rings):
		var history:Array[CellState] = _world_state.get_history(index)
		var current_history:CellState = history[_current_step]
		var current_cell_type:CellType = current_history.cell.cell_type \
			if current_history and current_history.cell else null
		var displayed_history:CellState = history[_displayed_step] \
			if _displayed_step != -1 else null
		var displayed_cell_type:CellType = displayed_history.cell.cell_type \
			if displayed_history and displayed_history.cell else null
		if displayed_cell_type != current_cell_type:
			_set_cell_appearance(index, current_cell_type)
		_set_cell_state(index, current_history)
	_displayed_step = _current_step

func _run_process(delta:float) -> void:
	
	if _current_step > _loaded_steps:
		return
		
	_step_delta += _run_steps_per_second * delta
	if _step_delta < 1.0:
		return
		
	var step_delta := floori(_step_delta)
	_step_delta -= step_delta
	var new_step := mini(_current_step + step_delta, _loaded_steps)
	_set_step(new_step)

func _set_cell_appearance(index:HexIndex, cell_type:CellType):
	var cell_appearance:CellAppearance = cell_type.cell_appearance.instantiate() \
		if cell_type else null
	if cell_appearance != null:
		cell_appearance.index = index
	var current_cell_appearance:CellAppearance = _grid.set_hex_content(index, cell_appearance)
	if current_cell_appearance: current_cell_appearance.queue_free()
	
func _set_cell_state(index:HexIndex, cell_state:CellState):
	var cell_appearance:CellAppearance = _grid.get_hex_content(index)
	if cell_appearance:
		cell_appearance.set_state(cell_state)
	if index == _index_shown:
		_update_shown_cell()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ToggleDebugPanel"):
		_debug_panel.visible = not _debug_panel.visible
