class_name HexStore extends RefCounted

var _map:Dictionary[HexIndex, Variant] = {}

func set_content(index:HexIndex, value:Variant) -> void:
	if value == null:
		_map.erase(index)
	else:
		_map.set(index, value)

func clear_content(index:HexIndex) -> void:
	set_content(index, null)

func get_content(index:HexIndex, default:Variant = null) -> Variant:
	return _map.get(index, default)

func has_content_at(index:HexIndex) -> bool:
	return _map.has(index)
	
func get_all_content() -> Array[Variant]:
	return _map.values()

func get_all_indexes() -> Array[HexIndex]:
	return _map.keys()
	
func visit_all(callback:Callable) -> void:
	for index in get_all_indexes():
		var value = get_content(index)
		callback.call(index, value)

func clear_all_content() -> void:
	_map = {}
	
func size() -> int:
	return _map.size()
	
func duplicate() -> HexStore:
	var new = HexStore.new()
	visit_all(new.set_content)
	return new

func get_ring_content(center:HexIndex, radius:int) -> Array[Variant]:
	return center.ring(radius).map(get_content)

func visit_ring(center:HexIndex, radius:int, callback:Callable) -> void:
	for index in center.ring(radius):
		var content = get_content(index)
		callback.call(index, content)
		
func find_max_distance() -> int:
	var max_distance:int = 0
	for index in get_all_indexes():
		var distance:int = index.distance_to_center()
		if distance > max_distance:
			max_distance = distance
	return max_distance

func serialize(serialize_value:Callable) -> Variant:
	return get_all_indexes().map(
		func (index): 
			return [index.serialize(), serialize_value.call(get_content(index))]
	)

static func deserialize(data:Variant, deserialize_value:Callable) -> HexStore:
	var hex_store = HexStore.new()
	for entry in data:
		hex_store.set_content(
			HexIndex.deserialize(entry[0]),
			deserialize_value.call(entry[1])
		)
	return hex_store
