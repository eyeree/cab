class_name Gene extends RefCounted

var _cell_ref:WeakRef
var cell:Cell:
	get: return _cell_ref.get_ref()

var _gene_type:GeneType
var gene_type:GeneType:
	get:
		if _gene_type == null:
			_gene_type = load(self.resource_path.get_basename() + "_type.tres")
		return _gene_type
		
func _init(cell_:Cell) -> void:
	_cell_ref = weakref(cell_)

var energy_wanted:int = 0

func perform_actions() -> void:
	pass
				
func update_state() -> void:
	pass

func apply_damage_resistance(_source_index:HexIndex, _damage_amount:int, _damage_type:Cell.DamageType) -> int:
	return 0
	
func init_cell() -> void:
	pass
	
func add_state(gene_state:GeneState) -> void:
	cell.state.substates.append(gene_state)
	
func provides_edge_attribute(_attribute:StringName) -> bool:
	return false
	
func get_edge_attribute_value(_direction:HexIndex.HexDirection, _attribute:StringName) -> float:
	return 0.0

func provides_cell_attribute(_attribute:StringName) -> bool:
	return false

func get_cell_attribute_value(_attribute:StringName) -> float:
	return 0.0	
