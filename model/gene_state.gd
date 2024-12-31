class_name GeneState extends RefCounted

static var _serialization = SerializationUtil.register(GeneState) \
	.ignore_properties(GeneState, ['cell'])

var gene:Gene
var cell:Cell

func use_energy(index:HexIndex, world:World, cell:Cell) -> void:
	pass
	
func aquire_energy(index:HexIndex, world:World, cell:Cell) -> void:
	pass
