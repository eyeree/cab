class_name Cell extends Node3D

@export var genome:Genome
@export var type:CellType

var creator:Cell

func step(index:HexIndex, battle:Battle) -> bool:
	return false

func resolve_conflicting_create(other:Cell) -> Cell:
	return other
