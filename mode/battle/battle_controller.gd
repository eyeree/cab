class_name BattleController extends Node

@export_file("*.tscn") var content_path:String

@onready var _step_button: Button = %StepButton
@onready var _reset_button: Button = %ResetButton
@onready var _run_button: Button = %RunButton
@onready var _pause_button: Button = %PauseButton
@onready var _run_speed_slider: HSlider = %RunSpeedSlider
@onready var _grid: Grid = %Grid

const _min_run_step_delta:float = 0.05
const _max_run_step_delta:float = 2.0

var _run_step_delta:float = 0.5
var _is_running:bool = false

var _step_timer:SceneTreeTimer = null

var _battle:Battle = Battle.new()

func _ready() -> void:
	
	_step_button.pressed.connect(_step)
	_reset_button.pressed.connect(_reset)
	_run_button.pressed.connect(_run)
	_pause_button.pressed.connect(_pause)
	
	_run_speed_slider.value = remap(_run_step_delta, _max_run_step_delta, _min_run_step_delta, _run_speed_slider.min_value, _run_speed_slider.max_value)
	_run_speed_slider.value_changed.connect(_on__run_speed_changed)
	
	_grid.mouse_entered_hex.connect(_on_mouse_entered_hex)
	_grid.mouse_exited_hex.connect(_on_mouse_exited_hex)
	
	_setup()
	
	_reset()
	_pause()
	
func _on_mouse_entered_hex(index:HexIndex):
	_grid.set_selected_index(index)

func _on_mouse_exited_hex(_index:HexIndex):
	_grid.clear_selected_index()

func _setup():
	var content_scene:PackedScene = load(content_path)
	_grid.set_hex_content(HexIndex.CENTER, content_scene.instantiate())

	# for index in HexIndex.CENTER.ring(2):
	# 	var content:Node3D = content_scene.instantiate()
	# 	_grid.set_hex_content(index, content)
	
func _step() -> void:
	prints('step')
	_reset_button.disabled = false
	if _is_running:	_start_step_timer()

func _reset() -> void:
	_reset_button.disabled = true

func _run() -> void:
	_step_button.disabled = true
	_run_button.disabled = true
	_pause_button.disabled = false
	_is_running = true
	_step()

func _pause() -> void:
	_step_button.disabled = false
	_run_button.disabled = false
	_pause_button.disabled = true
	_is_running = false
	_cancel_step_timer()
	
func _cancel_step_timer() -> void:
	if _step_timer:
		_step_timer.timeout.disconnect(_step)
		_step_timer = null

func _start_step_timer() -> void:
	_cancel_step_timer()
	_step_timer = get_tree().create_timer(_run_step_delta)
	_step_timer.timeout.connect(_step)
	
func _on__run_speed_changed(value:float) -> void:
	_run_step_delta = remap(value, _run_speed_slider.min_value, _run_speed_slider.max_value, _max_run_step_delta, _min_run_step_delta)
	if _is_running: _start_step_timer()

	
