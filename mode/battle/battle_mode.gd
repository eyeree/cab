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

const _min_run_speed_delta:float = 0.01
const _max_run_speed_delta:float = 2.0
@export var _run_speed_curve:Curve

var _is_running:bool = false
var _run_timer:SceneTreeTimer = null
var _run_waiting:bool = false

var _world:World = null
var _world_history:WorldHistory = null

var _selected_index:HexIndex = HexIndex.INVALID
var _mouse_index:HexIndex = HexIndex.INVALID

var _num_steps:int
var _current_step:int
var _displayed_step:int
var _loaded_steps:int

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
	
	_grid.mouse_entered_hex.connect(_on_mouse_entered_hex)
	_grid.mouse_exited_hex.connect(_on_mouse_exited_hex)
	_grid.hex_selected.connect(_on_hex_selected)

	battle()
	
func _on_mouse_entered_hex(index:HexIndex):
	_grid.set_selected_index(index)
	_show_cell(index)
	_mouse_index = index

func _on_mouse_exited_hex(_index:HexIndex):
	_show_selected_cell()

func _on_hex_selected(index:HexIndex):
	_selected_index = index
	_grid.set_highlighted_indexes([_selected_index])
	_show_selected_cell()

func _on_world_cell_changed(index:HexIndex, cell:Cell) -> void:
	_grid.set_hex_content(index, cell.cell_appearance)
	if index == _mouse_index:
		_show_cell(_mouse_index)
	elif index == _selected_index:
		_show_cell(_selected_index)

func _show_cell(_index:HexIndex) -> void:
	pass
	# FIX
	#var cell:Cell = _world.get_cell(index)
	#_cell_details_panel.show_cell(cell)

func _show_selected_cell() -> void:
	_grid.clear_selected_index()
	_mouse_index = HexIndex.INVALID
	if _selected_index == HexIndex.INVALID:
		_cell_details_panel.hide_panel()
	else:
		_show_cell(_selected_index)

class BattleOptions extends RefCounted:
	var rings:int = 10
	var steps:int = 500
	var initial_content:HexStore
	
func battle(options:BattleOptions = BattleOptions.new()) -> void:
	
	_grid.clear_all_hex_content()
	
	_num_steps = options.steps
	_current_step = 0
	_displayed_step = -1
	_loaded_steps = 0

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
		
	_countdown()
	
func _exit_tree() -> void:
	if _load_thread and _load_thread.is_alive():
		_stop_loading = true
		_load_thread.wait_to_finish()
		
func _load(battle_options:BattleOptions) -> void:
	
	battle_options.rings = _grid.rings # FIX
	battle_options.initial_content = _get_initial_content() # FIX
	
	_world_history = WorldHistory.new(battle_options.rings, battle_options.steps)
	
	var world_options = World.WorldOptions.new()
	world_options.rings = battle_options.rings
	world_options.initial_content = battle_options.initial_content
	world_options.world_history = _world_history
	_world = World.new(world_options)
	
	if OS.has_feature('nothreads'):
		
		_load_in_process = true
	
	else:
		_load_started.call_deferred()
		for step_number in range(1, _num_steps + 1):
			var start_ms:int = Time.get_ticks_msec()
			_world.step(step_number)
			var end_ms:int = Time.get_ticks_msec()
			_load_progress.call_deferred(step_number, end_ms - start_ms)
			if _stop_loading: break
		_load_finished.call_deferred()
		
var _load_in_process:bool = false

func _process(_delta: float) -> void:
	if not _load_in_process: return
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
			_load_in_process = false
			_load_finished()
			break

func _load_started() -> void:
	_update_grid()

func _load_progress(steps_done:int, ms_per_step:float) -> void:
	var was_waiting = _current_step > _loaded_steps and _current_step <= steps_done
	_loaded_steps = steps_done
	_load_progress_bar.value = _loaded_steps
	if _is_running and _run_waiting and _current_step + 1 == _loaded_steps:
		_run_waiting = false
		_next_step()
	elif was_waiting:
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
	_set_step(0)
	_run()
	
func _get_initial_content() -> HexStore:
	
	var genome1 = Genome.new()
	genome1.name = "Genome1"
	genome1.appearance_set = preload("res://appearance/simple_a/simple_a_appearance_set.tres")
	genome1.add_gene(AbsorbNutrientsGene)
	genome1.add_gene(RepairDamageGene)
	genome1.add_gene(ProduceCellGene)
	
	var cell_type_1a = genome1.add_cell_type()
	cell_type_1a.name = '1A'
	cell_type_1a.cell_appearance = genome1.appearance_set.get_cell_appearance_by_name('simple_a_cell_a')
	cell_type_1a.add_gene(AbsorbNutrientsGene)
	cell_type_1a.add_gene(RepairDamageGene)
	cell_type_1a.add_gene(ProduceCellGene)

	var genome2 = Genome.new()
	genome2.name = "Genome2"
	genome2.appearance_set = preload("res://appearance/simple_b/simple_b_appearance_set.tres")
	genome2.add_gene(AbsorbNutrientsGene)
	genome2.add_gene(RepairDamageGene)
	genome2.add_gene(ProduceCellGene)

	var cell_type_2a = genome2.add_cell_type()
	cell_type_2a.name = '2A'
	cell_type_2a.cell_appearance = genome2.appearance_set.get_cell_appearance_by_name('simple_b_cell_b')
	cell_type_2a.add_gene(AbsorbNutrientsGene)
	cell_type_2a.add_gene(RepairDamageGene)
	cell_type_2a.add_gene(ProduceCellGene)

	var initial_content:HexStore = HexStore.new()	
	
	initial_content.set_content(HexIndex.CENTER.diagonal_neighbor(HexIndex.HexDiagonal.N), cell_type_1a.create_cell())
	initial_content.set_content(HexIndex.CENTER.diagonal_neighbor(HexIndex.HexDiagonal.SE), cell_type_2a.create_cell())
	initial_content.set_content(HexIndex.CENTER.diagonal_neighbor(HexIndex.HexDiagonal.SW), cell_type_2a.create_cell())

	return initial_content
	
func _on_current_step_changed(value) -> void:
	_set_step(value)
	if _is_running and _run_waiting and _current_step <= _loaded_steps:
		_start_run_timer()
	
func _first_step() -> void:
	_set_step(0)

func _previous_step() -> void:
	if _current_step > 0:
		_set_step(_current_step - 1)
	else:
		prints('_previous_step error', _current_step)
	
func _run() -> void:
	_run_waiting = false
	_is_running = true
	_next_step()

func _pause() -> void:
	_is_running = false
	_cancel_run_timer()
	_update_ui()
	
func _next_step() -> void:
	if _current_step < _num_steps:
		var next_step = _current_step + 1
		if _is_running and next_step > _loaded_steps:	
			_run_waiting = true		
		else:
			if _is_running:
				if next_step == _num_steps:
					_is_running = false
				else:
					_start_run_timer()
			_set_step(next_step)
	else:
		prints('_next_step error', _current_step, _num_steps)

func _last_step() -> void:
	_is_running = false
	_set_step(_num_steps)

func _cancel_run_timer() -> void:
	if _run_timer:
		_run_timer.timeout.disconnect(_on_run_timer)
		_run_timer = null

func _start_run_timer() -> void:
	_cancel_run_timer()
	var delta:float = remap(
		_run_speed_curve.sample(_run_speed_slider.value), 
		0.0, 1.0,
		_max_run_speed_delta, _min_run_speed_delta)
	_run_timer = get_tree().create_timer(delta)
	_run_timer.timeout.connect(_on_run_timer)
	
func _on_run_timer() -> void:
	_next_step()
	
func _on_run_speed_changed(_value:float) -> void:
	if _is_running: _start_run_timer()
	
func _set_step(step_number:int) -> void:
	_current_step = step_number
	_update_ui()
	if _current_step > _loaded_steps:
		_wait_for_load()
	else:
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
		
func _wait_for_load() -> void:
	_overlay_label.text = "Loading..."
	_overlay_panel.visible = true
	
func _update_grid() -> void:
	_overlay_panel.visible = _displayed_step == -1
	for index:HexIndex in HexIndex.CENTER.spiral(_grid.rings):
		var history:Array[Dictionary] = _world_history.get_history(index)
		var current_history:Dictionary = history[_current_step]
		var cell_type = current_history.get('cell_type')
		if _displayed_step == -1 or history[_displayed_step].get('cell_type') != cell_type:
			_set_cell_appearance(index, cell_type)
		_set_cell_state(index, current_history)
	_displayed_step = _current_step

func _set_cell_appearance(index:HexIndex, cell_type:CellType):
	var cell_appearance:CellAppearance = cell_type.cell_appearance.instantiate() \
		if cell_type else null
	var current_cell_appearance:CellAppearance = _grid.set_hex_content(index, cell_appearance)
	if current_cell_appearance: current_cell_appearance.queue_free()
	
func _set_cell_state(index:HexIndex, state:Dictionary):
	var cell_appearance:CellAppearance = _grid.get_hex_content(index)
	if cell_appearance:
		cell_appearance.set_state(state)
	
#func _notification(what):
	#if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#if _load_thread and _load_thread.is_alive():
			#_load_thread.
		#get_tree().quit() 
