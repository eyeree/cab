@tool
class_name Level extends Resource

@export var rings:int = 5
@export var steps:int = 500
@export var genomes:Array[Genome] = []

@export var serialized_content:Array:
	set(value): 
		#prints('serialized_content set')
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

var _should_emit_changed := true
var _content_changed := false

func _init() -> void:
	content.content_changed.connect(_on_content_changed)
	
func _on_content_changed(_index:HexIndex, _old_content:Variant, _new_content:Variant):
	#prints('_on_content_changed', _should_emit_changed)
	if _should_emit_changed:
		_content_changed = true
		emit_changed()

func _deserialize_content(serialized_content_:Array) -> void:
	#prints('_deserialize_content', serialized_content_.size())
	_should_emit_changed = false
	content.clear_all_content()
	content.deserialize(serialized_content_)
	_should_emit_changed = true
	
func _serialize_content() -> Array:
	#prints('_serialize_content', content.size())
	return content.serialize()
