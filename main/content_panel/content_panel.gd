class_name ContentPanel extends HBoxContainer

@onready var _new_level_button: Button = %NewLevelButton
@onready var _save_level_button: Button = %SaveLevelButton
@onready var _load_level_button: Button = %LoadLevelButton
@onready var _level_file_name: Label = %LevelFileName

@onready var _save_level_file_dialog: FileDialog = %SaveLevelFileDialog
@onready var _load_level_file_dialog: FileDialog = %LoadLevelFileDialog

signal level_changed(new_level:Level)
signal dialog_opened()
signal dialog_closed()

const LEVEL_DIR_NAME = 'level'
const LEVEL_PATH := 'user://' + LEVEL_DIR_NAME
const LEVEL_PATH_PREFIX := LEVEL_PATH + '/'
const LEVEL_EXTENSION := ".cab_level"
const LEVEL_FILTERS := ['*' + LEVEL_EXTENSION + ';Cellular AutoBata Level;application/json']

const GENOME_DIR_NAME := 'genome'
const GENOME_PATH := 'user://' + GENOME_DIR_NAME
const GENOME_EXTENSION := ".cab_genome"

func _ready() -> void:
	
	_new_level_button.pressed.connect(_new_level)
	_save_level_button.pressed.connect(_save_level)
	_load_level_button.pressed.connect(_load_level)
	
	_save_level_file_dialog.file_selected.connect(_on_save_level_file_selected)
	_save_level_file_dialog.filters = LEVEL_FILTERS
	_save_level_file_dialog.root_subfolder = LEVEL_DIR_NAME
	
	_load_level_file_dialog.file_selected.connect(_on_load_level_file_selected)
	_load_level_file_dialog.filters = LEVEL_FILTERS
	_load_level_file_dialog.root_subfolder = LEVEL_DIR_NAME
	
	_save_level_file_dialog.get_cancel_button().pressed.connect(_on_file_dialog_canceled)
	_load_level_file_dialog.get_cancel_button().pressed.connect(_on_file_dialog_canceled)

	_level_file_name.text = ""
	
func _new_level():
	pass
	
func _save_level():
	dialog_opened.emit()
	_save_level_file_dialog.show()
	
func _load_level():
	dialog_opened.emit()
	_load_level_file_dialog.show()

func _on_save_level_file_selected(path: String):
	dialog_closed.emit()
	_set_level_file_name(path)
	
func _on_load_level_file_selected(path: String):
	dialog_closed.emit()
	_set_level_file_name(path)

func _set_level_file_name(path: String):
	_level_file_name.text = path.replace(LEVEL_PATH_PREFIX, '').replace(LEVEL_EXTENSION, '')
	
func _on_file_dialog_canceled():
	dialog_closed.emit()
	
static func _static_init() -> void:
	_init_user_dirs()
	
static func _init_user_dirs():
	prints("User Path:", ProjectSettings.globalize_path("user://"))	
	DirAccess.make_dir_recursive_absolute(LEVEL_PATH)
	DirAccess.make_dir_recursive_absolute(GENOME_PATH)
