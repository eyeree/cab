class_name GeneConfig extends RefCounted

var gene_type:GeneType

func _init(gene_type_:GeneType) -> void:
	gene_type = gene_type_

func create_gene(_cell:Cell, _progenitor:Cell) -> Gene:
	push_error('GeneConfig for GeneType %s did not override create_gene' % [gene_type.name])
	return null

func get_energy_cost() -> int:
	return gene_type.energy_cost
