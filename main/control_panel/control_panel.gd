class_name ControlPanel extends VBoxContainer

@onready var _first_step_button: Button = %FirstStepButton
@onready var _previous_step_button: Button = %PreviousStepButton
@onready var _run_button: Button = %RunButton
@onready var _pause_button: Button = %PauseButton
@onready var _next_step_button: Button = %NextStepButton
@onready var _last_step_button: Button = %LastStepButton
@onready var _current_step_slider: HSlider = %CurrentStepSlider
@onready var _load_progress_bar: ProgressBar = %LoadProgressBar
@onready var _run_speed_slider: HSlider = %RunSpeedSlider
@onready var _current_step_value: Label = %CurrentStepValue
@onready var _num_steps_value: Label = %NumStepsValue
@onready var _num_steps_slider: HSlider = %NumStepsSlider
@onready var _grid_size_slider: HSlider = %GridSizeSlider

var current_step:int = 0
var step_count:int = 0
var ring_count:int = 0

signal current_step_changed(value:int)
signal step_count_changed(value:int)
signal ring_count_changed(value:int)

var _is_running:bool = false
var _run_steps_per_second:float
var _step_delta:float = 0.0

var _loaded_steps:int = 0
var loaded_steps:int:
	get: return _loaded_steps
	set(value):
		_loaded_steps = value
		_load_progress_bar.value = value
		
func _ready() -> void:

	_first_step_button.pressed.connect(_first_step)
	_previous_step_button.pressed.connect(_previous_step)
	_run_button.pressed.connect(_run)
	_pause_button.pressed.connect(_pause)
	_next_step_button.pressed.connect(_next_step)
	_last_step_button.pressed.connect(_last_step)
	
	_current_step_slider.value_changed.connect(_on_current_step_changed)
	_current_step_slider.set_value_no_signal(0)
	
	_grid_size_slider.value_changed.connect(_on_grid_size_changed)
	_on_grid_size_changed(_grid_size_slider.value)
	
	_num_steps_slider.value_changed.connect(_on_num_steps_changed)
	_on_num_steps_changed(_num_steps_slider.value)
	
	_run_speed_slider.value_changed.connect(_on_run_speed_changed)
	_on_run_speed_changed(_run_speed_slider.value)
	
	_update_ui()

func _process(delta: float) -> void:
	if _is_running: _process_run(delta)
	
func _on_current_step_changed(value) -> void:
	_set_step(value)
	
func _first_step() -> void:
	_set_step(0)

func _previous_step() -> void:
	_set_step(current_step - 1)
	
func _run() -> void:
	_is_running = true
	_step_delta = 0.0
	_next_step()

func _pause() -> void:
	_is_running = false
	_update_ui()
	
func _next_step() -> void:
	_set_step(current_step + 1)

func _last_step() -> void:
	_set_step(step_count)

func _on_run_speed_changed(value:float) -> void:
	_run_steps_per_second = value
	
func _process_run(delta:float) -> void:
	
	if current_step > _loaded_steps:
		return
		
	_step_delta += _run_steps_per_second * delta
	if _step_delta < 1.0:
		return
		
	var step_delta := floori(_step_delta)
	_step_delta -= step_delta
	var new_step := mini(current_step + step_delta, _loaded_steps)
	_set_step(new_step)
	
func _set_step(step_number:int) -> void:
	
	if step_number < 0:
		step_number = 0
	
	if step_number > step_count:
		step_number = step_count
		
	if step_number == current_step:
		return
		
	current_step = step_number
	
	if current_step == step_count:
		_is_running = false
	
	_update_ui()
	
	current_step_changed.emit(current_step)
	
func _update_ui() -> void:
	_first_step_button.disabled = current_step == 0
	_previous_step_button.disabled = current_step == 0 or _is_running
	_run_button.disabled = current_step == step_count or _is_running
	_pause_button.disabled = not _is_running
	_next_step_button.disabled = current_step == step_count or _is_running
	_last_step_button.disabled = current_step == step_count
	_current_step_slider.set_value_no_signal(current_step)
	_current_step_value.text = str(current_step)
	_grid_size_slider.editable = current_step == 0
	_num_steps_slider.editable = current_step == 0
		
func _on_num_steps_changed(value:float) -> void:
	step_count = roundi(value)
	_num_steps_value.text = str(step_count)
	_current_step_slider.max_value = step_count
	_load_progress_bar.max_value = step_count
	step_count_changed.emit(step_count)
	
func _on_grid_size_changed(value:float) -> void:
	ring_count = roundi(value)
	ring_count_changed.emit(ring_count)

func reset(ring_count_:int, step_count_:int) -> void:
	current_step = 0
	ring_count = ring_count_
	step_count = step_count_
	_is_running = false
	_loaded_steps = 0
	_update_ui()
