class_name LevelPanel extends PanelContainer

@onready var _new_level_button: Button = %NewLevelButton
@onready var _save_level_button: Button = %SaveLevelButton
@onready var _load_level_button: Button = %LoadLevelButton
@onready var _level_file_name: Label = %LevelFileName

@onready var _save_level_file_dialog: FileDialog = %SaveLevelFileDialog
@onready var _load_level_file_dialog: FileDialog = %LoadLevelFileDialog

var state:LevelEditorState

signal level_changed()
signal dialog_opened()
signal dialog_closed()

const GENOME_DIR_NAME := 'genome'
const GENOME_PATH := 'user://' + GENOME_DIR_NAME
const GENOME_EXTENSION := ".cab_genome"

const DEFAULT_LEVEL_PATH := 'res://level/default.cab_level.tres'

func _ready() -> void:
	
	_new_level_button.pressed.connect(_new_level)
	_save_level_button.pressed.connect(_save_level)
	_load_level_button.pressed.connect(_load_level)
	
	_save_level_file_dialog.file_selected.connect(_on_save_level_file_selected)
	_save_level_file_dialog.filters = Level.LEVEL_FILTERS
	_save_level_file_dialog.root_subfolder = Level.LEVEL_DIR_NAME
	
	_load_level_file_dialog.file_selected.connect(_on_load_level_file_selected)
	_load_level_file_dialog.filters = Level.LEVEL_FILTERS
	_load_level_file_dialog.root_subfolder = Level.LEVEL_DIR_NAME
	
	_save_level_file_dialog.close_requested.connect(_on_file_dialog_canceled)
	_load_level_file_dialog.close_requested.connect(_on_file_dialog_canceled)
	_save_level_file_dialog.get_cancel_button().pressed.connect(_on_file_dialog_canceled)
	_load_level_file_dialog.get_cancel_button().pressed.connect(_on_file_dialog_canceled)
	
	state = LevelEditorState.load()
	if state.current_level_path == '' or not FileAccess.file_exists(state.current_level_path):
		_load_default_level()
	else:
		_load_level_resource(state.current_level_path)

func _load_default_level() -> void:
	if not FileAccess.file_exists(Level.INITIAL_LEVEL_PATH):
		ResourceSaver.save(Level.get_default_level(), Level.INITIAL_LEVEL_PATH)
	_load_level_resource(Level.INITIAL_LEVEL_PATH)
		
func _new_level():
	var path = _get_next_level_path()
	ResourceSaver.save(Level.get_default_level(), path)
	_load_level_resource(path)
	
func _get_next_level_path() -> String:
	var n := 1
	var path := Level.LEVEL_PATH_TEMPALTE % [n]
	while ResourceLoader.exists(path):
		n += 1
		path = Level.LEVEL_PATH_TEMPALTE % [n]
	return path		
	
func _save_level():
	dialog_opened.emit()
	_save_level_file_dialog.show()
	
func _load_level():
	dialog_opened.emit()
	_load_level_file_dialog.show()

func _on_save_level_file_selected(path: String):
	dialog_closed.emit()
	ResourceSaver.save(Level.current, path)
	_load_level_resource(path)
	
func _on_load_level_file_selected(path: String):
	dialog_closed.emit()
	_load_level_resource(path)

func _on_file_dialog_canceled():
	dialog_closed.emit()
	
func _load_level_resource(path:String) -> void:
	if Level.current:
		Level.current.level_modified.disconnect(_on_level_modified)
	Level.current = ResourceLoader.load(path)
	if Level.current == null:
		if path == Level.INITIAL_LEVEL_PATH:
			DirAccess.remove_absolute(Level.INITIAL_LEVEL_PATH)
		_load_default_level()
	else:
		Level.current.level_modified.connect(_on_level_modified)
		state.current_level_path = path
		state.save()
		_level_file_name.text = path.replace(Level.LEVEL_PATH_PREFIX, '').replace(Level.LEVEL_EXTENSION, '')
		_change_number = 0
		level_changed.emit()
	
var _change_number := 0
func _on_level_modified() -> void:
	_change_number += 1
	var my_change_number = _change_number
	await get_tree().create_timer(0.5).timeout
	if _change_number == my_change_number:
		Level.current.save()
