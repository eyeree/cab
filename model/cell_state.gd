class_name CellState extends Node

var cell:Cell

var start_energy:int
var end_energy:int
var new_energy:int
var max_energy:int
var energy_wanted:int

var start_life:int
var end_life:int
var new_life:int
var max_life:int

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
