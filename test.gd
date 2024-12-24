extends Node2D

class HexIndex extends RefCounted:
	
	static var INVALID:HexIndex = HexIndex.new(2147483647, 2147483647, 2147483647)
		
	var _v:Vector3i
	
	var q:int:
		get():
			return _v.x
		set(value):
			_v.x = value

	var r:int:
		get():
			return _v.y
		set(value):
			_v.y = value

	var s:int:
		get():
			return _v.z
		set(value):
			_v.z = value
	
	func _init(q:int, r:int, s:int):
		_v = Vector3i(q, r, s)

	
var dict:Dictionary[Vector3i, String] = {}
var vdict:Dictionary[Vector3i, String] = {}

enum Foo { A, B, C }
func _ready():
	
	for f in Foo:
		prints(f)
	
	#var k = HexIndex.new(1, 2, 3)
	#dict.set(k._v, "foo")
	#prints(dict.get(k._v))
	#k._v.x = 10
	#prints(dict.get(k._v))
	#
	#vdict.set(Vector3i(1, 2, 3), "foo")
	#prints(vdict.get(Vector3i(1, 2, 3)))
