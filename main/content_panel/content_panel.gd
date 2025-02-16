class_name ContentPanel extends HBoxContainer

@onready var _new_level_button: Button = %NewLevelButton
@onready var _save_level_button: Button = %SaveLevelButton
@onready var _load_level_button: Button = %LoadLevelButton
@onready var _level_file_name: Label = %LevelFileName

@onready var _save_level_file_dialog: FileDialog = %SaveLevelFileDialog
@onready var _load_level_file_dialog: FileDialog = %LoadLevelFileDialog

var level:Level

signal level_changed()
signal dialog_opened()
signal dialog_closed()

const LEVEL_DIR_NAME = 'level'
const LEVEL_PATH := 'user://' + LEVEL_DIR_NAME
const LEVEL_PATH_PREFIX := LEVEL_PATH + '/'
const LEVEL_EXTENSION := ".cab_level.tres"
const LEVEL_FILTERS := ['*' + LEVEL_EXTENSION + ';Cellular AutoBata Level;text/plain']

const GENOME_DIR_NAME := 'genome'
const GENOME_PATH := 'user://' + GENOME_DIR_NAME
const GENOME_EXTENSION := ".cab_genome"

const DEFAULT_LEVEL_PATH := 'res://level/default.cab_level.tres'

func _ready() -> void:
	
	level = _load_level_resource(DEFAULT_LEVEL_PATH)
	_level_file_name.text = '(unsaved)'
	
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

func _new_level():
	level = _load_level_resource(DEFAULT_LEVEL_PATH)
	_level_file_name.text = '(unsaved)'
	level_changed.emit()
	
func _save_level():
	dialog_opened.emit()
	_save_level_file_dialog.show()
	
func _load_level():
	dialog_opened.emit()
	_load_level_file_dialog.show()

func _on_save_level_file_selected(path: String):
	dialog_closed.emit()
	_set_level_file_name(path)
	ResourceSaver.save(level, path)
	
func _on_load_level_file_selected(path: String):
	dialog_closed.emit()
	_set_level_file_name(path)
	level = _load_level_resource(path)
	level_changed.emit()

func _set_level_file_name(path: String):
	_level_file_name.text = path.replace(LEVEL_PATH_PREFIX, '').replace(LEVEL_EXTENSION, '')
	
func _on_file_dialog_canceled():
	dialog_closed.emit()
	
func _load_level_resource(path:String) -> Level:
	return ResourceLoader.load(path).duplicate()
	
static func _static_init() -> void:
	_init_user_dirs()
	
static func _init_user_dirs():
	prints("User Path:", ProjectSettings.globalize_path("user://"))	
	DirAccess.make_dir_recursive_absolute(LEVEL_PATH)
	DirAccess.make_dir_recursive_absolute(GENOME_PATH)

func _get_initial_level() -> Level:
	
	var initial_level := Level.new()
	
	var genome1 = Genome.new()
	genome1.name = "Genome1"
	genome1.appearance_set = preload("res://appearance/simple_a/simple_a_appearance_set.tres")
	genome1.add_gene(GenerateEnergyGene)
	genome1.add_gene(RepairDamageGene)
	genome1.add_gene(ProduceCellGene)
	initial_level.genomes.append(genome1)
	
	var cell_type_1a = genome1.add_cell_type()
	cell_type_1a.name = '1A'
	cell_type_1a.add_gene(GenerateEnergyGene)
	cell_type_1a.add_gene(RepairDamageGene)
	cell_type_1a.add_gene(ProduceCellGene)

	var genome2 = Genome.new()
	genome2.name = "Genome2"
	genome2.appearance_set = preload("res://appearance/simple_b/simple_b_appearance_set.tres")
	genome2.add_gene(GenerateEnergyGene)
	genome2.add_gene(RepairDamageGene)
	genome2.add_gene(ProduceCellGene)
	initial_level.genomes.append(genome2)

	var cell_type_2a = genome2.add_cell_type()
	cell_type_2a.name = '2A'
	cell_type_2a.cell_appearance_index = 1
	cell_type_2a.add_gene(GenerateEnergyGene)
	cell_type_2a.add_gene(RepairDamageGene)
	cell_type_2a.add_gene(ProduceCellGene)

	#level.content.set_content(HexIndex.CENTER, cell_type_1a)
	initial_level.content.set_content(HexIndex.from(-3, 0, 3), cell_type_1a)
	initial_level.content.set_content(HexIndex.from(2, 2, -4), cell_type_2a)
	initial_level.content.set_content(HexIndex.from(4, -2, -2), cell_type_2a)

	return initial_level
