class_name Gene extends RefCounted

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

func perform_actions(_index:HexIndex, _world:World, _cell:Cell, _cell_history:CellState) -> void:
	pass
				
func update_state(_index:HexIndex, _world:World, _cell:Cell, _cell_history:CellState) -> void:
	pass

func apply_damage_resistance(_damage_amount:int, _damage_type:Cell.DamageType) -> int:
	return 0
	
func init_cell(cell:Cell) -> void:
	pass
