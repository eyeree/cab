class_name Gene extends RefCounted
			
var energy_wanted:int = 0

func perform_actions(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass

func apply_damage_resistance(_damange_amount:int, _damange_type:Cell.DamageType) -> int:
	return 0
