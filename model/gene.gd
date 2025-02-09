class_name Gene extends RefCounted

var _cell_ref:WeakRef
var cell:Cell:
	get: return _cell_ref.get_ref()

func _init(cell_:Cell) -> void:
	_cell_ref = weakref(cell_)
		
# All gene derived classes must define:
#
#     static var gene_type_:SomeGeneType = SomeGeneType.new()
#
# GDScript resolves instance property access with static property values. So
# gene.gene_type should work, but isn't defined by Gene. You can use gene_type_
# as an alternative.

var gene_type:GeneType:
	get: 
		return self.get('gene_type_')

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
