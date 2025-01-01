class_name Test extends Node3D

func test(s:String, t:String = s + 'bar'):
	prints(s, t)
	
func _ready():
	test("foo")
