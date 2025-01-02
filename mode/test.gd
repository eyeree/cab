class_name Test extends Node3D

var x:int:
	set = _on_x_set
	
func _on_x_set(new_value:int):
	prints('_on_x_set', x, '->', new_value)
	x = new_value

func _init(x_:int = 10):
	x = x_
	
func _ready():
	x = 100
	prints(x)
	
