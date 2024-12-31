class_name GeneState extends RefCounted

static func _identify_ignored_properties(ignored_properties:Array[StringName]) -> void:
	ignored_properties.append('gene')
	ignored_properties.append('cell')

var gene:Gene
var cell:Cell

func use_energy(index:HexIndex, world:World, cell:Cell) -> void:
	pass
	
func aquire_energy(index:HexIndex, world:World, cell:Cell) -> void:
	pass

func serialize() -> Dictionary:
	return SerializationUtil.serialize_object(self)
	
static func deserialize(data:Dictionary, cell_:Cell) -> GeneState:
	var result = SerializationUtil.deserialize_object(data)
	result.cell = cell_
	return result
