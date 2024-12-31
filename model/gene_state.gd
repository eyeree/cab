class_name GeneState extends RefCounted

static func _static_init():
	SerializationUtil.register(GeneState)

var gene:Gene
var cell:Cell

func use_energy(index:HexIndex, world:World, cell:Cell) -> void:
	pass
	
func aquire_energy(index:HexIndex, world:World, cell:Cell) -> void:
	pass
