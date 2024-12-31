class_name HexStore extends RefCounted

static func _static_init():
	SerializationUtil.register(HexStore)

var _map:Dictionary[Vector3i, Variant] = {}

func set_content(index:HexIndex, value:Variant) -> void:
	_map.set(index._key, value)

func clear_content(index:HexIndex) -> void:
	set_content(index, null)

func get_content(index:HexIndex, default:Variant = null) -> Variant:
	return _map.get(index._key, default)

func has_index(index:HexIndex) -> bool:
	return _map.has(index._key)
	
func get_all_values() -> Array[Variant]:
	return _map.values()

func get_all_indexes() -> Array[HexIndex]:
	var indexes:Array[HexIndex] = []
	for key in _map.keys():
		var index:HexIndex = HexIndex.from_key(key)
		indexes.push_back(index)
	return indexes
	
func visit_all(callback:Callable) -> void:
	for index in get_all_indexes():
		var value = get_content(index)
		callback.call(index, value)

func clear_all_values() -> void:
	_map = {}
	
func duplicate() -> HexStore:
	var new = HexStore.new()
	visit_all(new.set_value)
	return new

func get_ring(center:HexIndex, radius:int) -> Array[Variant]:
	return center.ring(radius).map(get_content)

func visit_ring(center:HexIndex, radius:int, callback:Callable) -> void:
	for index in center.ring(radius):
		var value = get_content(index)
		callback.call(index, value)
		
func find_max_distance() -> int:
	var max_distance:int = 0
	for index in get_all_indexes():
		var distance:int = index.distance_to_center()
		if distance > max_distance:
			max_distance = distance
	return max_distance

func serialize(serialize_value:Callable) -> Variant:
	return get_all_indexes().map(
		func (index): return [index.serialize(), serialize_value.call(get_content(index))]
	)

static func deserialize(data:Variant, deserialize_value:Callable) -> HexStore:
	var hex_store = HexStore.new()
	for entry in data:
		hex_store.set_value(
			HexIndex.deserialize(entry[0]),
			deserialize_value.call(entry[1])
		)
	return hex_store
