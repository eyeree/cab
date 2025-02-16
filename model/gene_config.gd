class_name GeneConfig extends Resource

var _gene_type:GeneType
var gene_type:GeneType:
	get:
		if _gene_type == null:
			var path:String = get_script().resource_path.get_basename().replace("_gene_config", "_gene_type") + ".tres"
			_gene_type = load(path)
		return _gene_type

func create_gene(_cell:Cell) -> Gene:
	assert(false, 'GeneConfig for GeneType %s did not override create_gene' % [gene_type.name])
	return null

func get_energy_cost() -> int:
	return gene_type.energy_cost
