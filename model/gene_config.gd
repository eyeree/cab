class_name GeneConfig extends RefCounted

func serialize(ignore:Array[StringName] = []) -> Dictionary:
	return SerializationUtil.serialize_object(self, ignore)
	
func deserialize(data:Dictionary) -> void:
	SerializationUtil.deserialize_object(data, self)
