@tool
class_name Level extends Resource

const LEVEL_DIR_NAME = 'level'
const LEVEL_PATH := 'user://' + LEVEL_DIR_NAME
const LEVEL_PATH_PREFIX := LEVEL_PATH + '/'
const LEVEL_EXTENSION := ".cab_level.tres"
const LEVEL_FILTERS := ['*' + LEVEL_EXTENSION + ';Cellular AutoBata Level;text/plain']
const INITIAL_LEVEL_PATH := LEVEL_PATH_PREFIX + 'level_1' + Level.LEVEL_EXTENSION
const LEVEL_PATH_TEMPALTE := LEVEL_PATH_PREFIX + 'level_%d' + Level.LEVEL_EXTENSION
const DEFAULT_LEVEL_PATH := 'res://level/default.cab_level.tres'

static func _static_init() -> void:
	DirAccess.make_dir_recursive_absolute(LEVEL_PATH)
	
class LevelSignals:
	signal level_modified()
	
static var signals := LevelSignals.new()

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
