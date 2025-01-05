class_name Gene extends RefCounted
			
func perform_actions(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass
				
func update_state(_index:HexIndex, _world:World, _cell:Cell) -> void:
	pass

func damage_resistance(_damange_amount:int, _damange_type:Cell.DamageType) -> int:
	return 0
