class_name CellState extends Node

var cell_type:CellType
var cell_number:int

var start_energy:int
var end_energy:int
var new_energy:int
var max_energy:int
var energy_wanted:int

var start_life:int
var end_life:int
var new_life:int
var max_life:int

var actions:Array[Action] = []

func add_action(action:Action) -> void:
	actions.append(action)
	
func get_action(type:Variant) -> Action:
	for action in actions:
		if is_instance_of(action, type):
			return action
	return null
	
class Action extends RefCounted:
	pass
	
