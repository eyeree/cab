class_name GeneState extends RefCounted

var gene:Gene

func _init(gene_:Gene):
	gene = gene_
	
func perform_actions(index:HexIndex, world:World, cell:Cell) -> void:
	pass
	
func update_state(index:HexIndex, world:World, cell:Cell) -> void:
	pass
