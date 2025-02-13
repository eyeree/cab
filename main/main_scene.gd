class_name MainScene extends Node

@onready var _grid: HexGrid = %HexGrid
@onready var _cell_details_panel: CellViewPanel = %CellViewPanel
@onready var _control_panel: ControlPanel = %ControlPanel

@onready var _overlay_panel: Panel = %OverlayPanel

@onready var _debug_panel: PanelContainer = %DebugPanel
@onready var _debug_hex_index: Label = %DebugHexIndex

@onready var _world: World = %World

var _load_needed:bool = true

var _selected_index:HexIndex = HexIndex.INVALID
var _mouse_index:HexIndex = HexIndex.INVALID
var _index_shown:HexIndex = HexIndex.INVALID

var _initial_content:HexStore

func _ready() -> void:

	_initial_content = _get_initial_content()
	
	_control_panel.current_step_changed.connect(_on_current_step_changed)
	_control_panel.ring_count_changed.connect(_on_ring_count_changed)
	_control_panel.step_count_changed.connect(_on_step_count_changed)
	
	_grid.mouse_entered_hex.connect(_on_mouse_entered_hex)
	_grid.mouse_exited_hex.connect(_on_mouse_exited_hex)
	_grid.hex_selected.connect(_on_hex_selected)
	
	_world.load_started.connect(_load_started)
	_world.load_progress.connect(_load_progress)
	_world.load_finished.connect(_load_finished)
	
	GeneViewPanel.gene_signals.highlight_cell.connect(_highlight_cell)
	
	_update_grid()

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
	if _control_panel.current_step == 0:
		_update_shown_cell_config()
	else:
		_update_shown_cell_state()
		
func _update_shown_cell_state():
		var cell_state:CellState = _world.state.get_history_entry(
			_index_shown, 
			_control_panel.current_step)
		_cell_details_panel.show_cell_state(cell_state)
		
func _update_shown_cell_config():
	pass

func _show_selected_cell() -> void:
	_grid.clear_selected_index()
	_mouse_index = HexIndex.INVALID
	if _selected_index == HexIndex.INVALID:
		_cell_details_panel.hide_panel()
	else:
		_show_cell(_selected_index)

func _start_load() -> void:
	
	_control_panel.loaded_steps = 0
	_load_needed = false
	
	var world_options = World.WorldOptions.new()
	world_options.rings = _control_panel.ring_count
	world_options.steps = _control_panel.step_count
	world_options.initial_content = _initial_content
	_world.load(world_options)
		
func _load_started() -> void:
	pass

func _load_progress(loaded_steps:int) -> void:
	var was_waiting = _control_panel.current_step > _control_panel.loaded_steps \
		and _control_panel.current_step <= loaded_steps
	_control_panel.loaded_steps = loaded_steps
	if was_waiting:
		_overlay_panel.visible = false
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
		_update_grid_from_initial_content()
	else:
		_update_grid_from_world()

func _update_grid_from_world():
	var current_step := _control_panel.current_step
	for index:HexIndex in HexIndex.CENTER.spiral(_grid.rings):
		var cell_state:CellState = _world.state.get_history_entry(index, current_step)
		var cell_type:CellType = cell_state.cell.cell_type # if cell_state and cell_state.cell else null
		_set_cell_appearance(index, cell_type)
		_set_cell_state(index, cell_state)
	
func _update_grid_from_initial_content():
	for index:HexIndex in HexIndex.CENTER.spiral(_grid.rings):
		var cell_type:CellType = _initial_content.get_content(index)
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
	if index == _index_shown:
		_update_shown_cell()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ToggleDebugPanel"):
		_debug_panel.visible = not _debug_panel.visible

func _on_step_count_changed(_step_count:int) -> void:
	_reset_load()
	
func _on_ring_count_changed(ring_count:int) -> void:
	_grid.rings = ring_count
	_reset_load()
	_update_grid()
	
func _reset_load():
	_world.stop_loading()
	_load_needed = true
	_control_panel.loaded_steps = 0

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
	
