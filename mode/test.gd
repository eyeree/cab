class_name Test extends Node3D

class Foo:
	var foo:String = 'foo'
	var bar:int = 10

func _ready():
	var foo:Foo = Foo.new()
	prints(foo)
	
