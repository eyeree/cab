@tool
class_name Level extends Resource

const LEVEL_DIR_NAME = 'level'
const LEVEL_PATH := 'user://' + LEVEL_DIR_NAME
const LEVEL_PATH_PREFIX := LEVEL_PATH + '/'
const LEVEL_EXTENSION := ".cab_level.tres"
const LEVEL_FILTERS := ['*' + LEVEL_EXTENSION + ';Cellular AutoBata Level;text/plain']
const INITIAL_LEVEL_PATH := LEVEL_PATH_PREFIX + 'level_1' + Level.LEVEL_EXTENSION
const LEVEL_PATH_TEMPALTE := LEVEL_PATH_PREFIX + 'level_%d' + Level.LEVEL_EXTENSION

static func _static_init() -> void:
	prints("User directory:", OS.get_user_data_dir())
	DirAccess.make_dir_recursive_absolute(LEVEL_PATH)

static var current:Level = null
	
@warning_ignore("unused_signal")
signal level_modified()
	
@export var rings:int = 5
@export var steps:int = 500
@export var genomes:Array[Genome] = []

@export var serialized_content:Array:
	set(value): 
		#prints('serialized_content set', value.size())
		serialized_content = value
		_deserialize_content(value)
	get:
		#prints('serialized_content get', _content_changed)
		if _content_changed:
			#prints('serialized_content get', _content_changed)
			serialized_content = _serialize_content()
			_content_changed = false
		return serialized_content
		
var content:HexStore = HexStore.new()
var _content_changed := false

func _init() -> void:
	content.content_changed.connect(_on_content_changed)

func _on_content_changed(_index:HexIndex, _old_content:Variant, _new_content:Variant):
	#prints('_on_content_changed', _should_emit_changed)
	_content_changed = true

func _deserialize_content(serialized_content_:Array) -> void:
	#prints('_deserialize_content', serialized_content_.size())
	content.clear_all_content()
	content.deserialize(serialized_content_)
	_content_changed = false

func _serialize_content() -> Array:
	#prints('_serialize_content', content.size())
	return content.serialize()

func save() -> void:
	prints("Saving level", resource_path)
	ResourceSaver.save(self)

func modified():
	Level.current.level_modified.emit()
	if Level.current == self:
		Level.signals.current_level_modified.emit()
	
func get_hex_content(index:HexIndex) -> LevelHexContent:
	return content.get_content(index)

func set_hex_content(index:HexIndex, cell_type:CellType, orientation:HexIndex.HexDirection = HexIndex.HexDirection.E) -> LevelHexContent:
	var inital_hex_content := LevelHexContent.new()
	inital_hex_content.cell_type = cell_type
	inital_hex_content.orientation = orientation
	content.set_content(index, inital_hex_content)
	return inital_hex_content

static func get_default_level() -> Level:
	
	var level := Level.new()
	
	var genome1 = Genome.new()
	genome1.name = "Genome1"
	genome1.appearance_set = preload("res://appearance/simple_a/simple_a_appearance_set.tres")
	genome1.add_gene(GenerateEnergyGene)
	genome1.add_gene(RepairDamageGene)
	genome1.add_gene(ProduceCellGene)
	level.genomes.append(genome1)
	
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
	level.genomes.append(genome2)

	var cell_type_2a = genome2.add_cell_type()
	cell_type_2a.name = '2A'
	cell_type_2a.cell_appearance_index = 1
	cell_type_2a.add_gene(GenerateEnergyGene)
	cell_type_2a.add_gene(RepairDamageGene)
	cell_type_2a.add_gene(ProduceCellGene)

	#level.content.set_content(HexIndex.CENTER, cell_type_1a)
	level.set_hex_content(HexIndex.from(-3, 0, 3), cell_type_1a)
	level.set_hex_content(HexIndex.from(2, 2, -4), cell_type_2a)
	level.set_hex_content(HexIndex.from(4, -2, -2), cell_type_2a)

	return level

class Signals:
	@warning_ignore("unused_signal")
	signal current_level_modified()
	
static var signals := Signals.new()
