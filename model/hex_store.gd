class_name HexStore extends RefCounted

var _map:Dictionary[StringName, Variant] = {}

func set_value(index:HexIndex, value:Variant) -> void:
    _map.set(index._key, value)

func clear_value(index:HexIndex) -> void:
    set_value(index, null)

func get_value(index:HexIndex) -> Variant:
    return _map.get(index._key)

func has_index(index:HexIndex) -> bool:
    return _map.has(index._key)
    
func get_all_values() -> Array[Variant]:
    return _map.values()

func visit_all(callback:Callable) -> void:
    for key in _map.keys():
        var index:HexIndex = HexIndex.from_key(key)
        var value = get_value(index)
        callback.call(index, value)

func clear_all_values() -> void:
    _map = {}

func get_ring(center:HexIndex, radius:int) -> Array[Variant]:
    return center.ring(radius).map(get_value)

func visit_ring(center:HexIndex, radius:int, callback:Callable) -> void:
    for index in center.ring(radius):
        var value = get_value(index)
        callback.call(index, value)
