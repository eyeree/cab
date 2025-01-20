class_name CellState extends Node

var cell:Cell

var start_energy:int = 0
var end_energy:int = 0
var new_energy:int = 0
var max_energy:int = 0
var energy_wanted:int = 0

var start_life:int = 0
var end_life:int = 0
var new_life:int = 0
var max_life:int = 0

class Substate extends RefCounted:
	pass
	
var substates:Array[Substate] = []

func get_substate(type:Variant) -> Substate:
	for substate:Substate in substates:
		if is_instance_of(substate, type):
			return substate
	return null

func get_substates(type:Variant, dest:Array = []) -> Array:
	for substate:Substate in substates:
		if is_instance_of(substate, type):
			dest.append(substate)
	return dest

var is_dead:bool:
	get: return end_life + new_life <= 0
