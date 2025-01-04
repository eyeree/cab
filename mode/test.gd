class_name Test extends Node3D
	
func _ready():
	foo(Array[Test])
	
func foo(x):
	prints(x)
	var y = x.new()
	prints(y)
