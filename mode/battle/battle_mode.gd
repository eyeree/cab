class_name BattleMode extends Node

@onready var _step_button: Button = %StepButton
@onready var _reset_button: Button = %ResetButton
@onready var _run_button: Button = %RunButton
@onready var _pause_button: Button = %PauseButton
@onready var _run_speed_slider: HSlider = %RunSpeedSlider
@onready var _grid: Grid = %Grid
@onready var cell_details_panel: CellDetailsPanel = %CellDetailsPanel

const _min_run_step_delta:float = 0.05
const _max_run_step_delta:float = 2.0

var _run_step_delta:float = 0.5
var _is_running:bool = false

var _step_timer:SceneTreeTimer = null

var _world:World = World.new()

var _selected_index:HexIndex = HexIndex.INVALID
var _mouse_index:HexIndex = HexIndex.INVALID

func _ready() -> void:
	
	_step_button.pressed.connect(_step)
	_reset_button.pressed.connect(_reset)
	_run_button.pressed.connect(_run)
	_pause_button.pressed.connect(_pause)
	
	_run_speed_slider.value = remap(_run_step_delta, _max_run_step_delta, _min_run_step_delta, _run_speed_slider.min_value, _run_speed_slider.max_value)
	_run_speed_slider.value_changed.connect(_on_run_speed_changed)
	
	_grid.mouse_entered_hex.connect(_on_mouse_entered_hex)
	_grid.mouse_exited_hex.connect(_on_mouse_exited_hex)
	_grid.hex_selected.connect(_on_hex_selected)

	_world.cell_changed.connect(_on_world_cell_changed)
	
	_setup()
	
	_reset()
	_pause()
	
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

func _show_cell(index:HexIndex) -> void:
	var cell:Cell = _world.get_cell(index)
	cell_details_panel.show_cell(cell)

func _show_selected_cell() -> void:
	_grid.clear_selected_index()
	_mouse_index = HexIndex.INVALID
	if _selected_index == HexIndex.INVALID:
		cell_details_panel.hide_panel()
	else:
		_show_cell(_selected_index)

func _setup():
	
	_grid.clear_all_hex_content()
	
	var world_options = World.WorldOptions.new()
	world_options.rings = _grid.rings
	world_options.initial_content = _get_initial_content()
	_world.init(world_options)

	_show_selected_cell()


func _get_initial_content() -> HexStore:
	
	var genome1 = Genome.new()
	genome1.name = "Genome1"
	genome1.appearance_set = preload("res://appearance/simple_a/simple_a_appearance_set.tres")
	genome1.add_gene(AbsorbEnergyGene)
	genome1.add_gene(RepairDamageGene)
	genome1.add_gene(ProduceCellGene)
	
	var cell_type_1a = genome1.add_cell_type()
	cell_type_1a.name = '1A'
	cell_type_1a.cell_appearance = genome1.appearance_set.get_cell_appearance_by_name('simple_a_cell_a')
	cell_type_1a.add_gene(AbsorbEnergyGene)
	cell_type_1a.add_gene(RepairDamageGene)
	cell_type_1a.add_gene(ProduceCellGene)

	var genome2 = Genome.new()
	genome2.name = "Genome2"
	genome2.appearance_set = preload("res://appearance/simple_b/simple_b_appearance_set.tres")
	genome2.add_gene(AbsorbEnergyGene)
	genome2.add_gene(RepairDamageGene)
	genome2.add_gene(ProduceCellGene)

	var cell_type_2a = genome2.add_cell_type()
	cell_type_2a.name = '2A'
	cell_type_2a.cell_appearance = genome2.appearance_set.get_cell_appearance_by_name('simple_b_cell_b')
	cell_type_2a.add_gene(AbsorbEnergyGene)
	cell_type_2a.add_gene(RepairDamageGene)
	cell_type_2a.add_gene(ProduceCellGene)

	var initial_content:HexStore = HexStore.new()	
	
	initial_content.set_content(HexIndex.CENTER.diagonal_neighbor(HexIndex.HexDiagonal.N), cell_type_1a.create_cell())
	initial_content.set_content(HexIndex.CENTER.diagonal_neighbor(HexIndex.HexDiagonal.SE), cell_type_2a.create_cell())
	initial_content.set_content(HexIndex.CENTER.diagonal_neighbor(HexIndex.HexDiagonal.SW), cell_type_2a.create_cell())

	return initial_content
	
func _step() -> void:
	_reset_button.disabled = false
	if _is_running:	_start_step_timer()
	_world.step()

func _reset() -> void:
	_reset_button.disabled = true
	_setup()

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
	
func _on_run_speed_changed(value:float) -> void:
	_run_step_delta = remap(value, _run_speed_slider.min_value, _run_speed_slider.max_value, _max_run_step_delta, _min_run_step_delta)
	if _is_running: _start_step_timer()

	
