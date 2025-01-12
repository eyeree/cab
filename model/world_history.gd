class_name WorldHistory extends RefCounted

var history:HexStore = HexStore.new()

func _init(radius:int, steps:int) -> void:
	for index in HexIndex.CENTER.spiral(radius):
		var hex_history:Array[Dictionary] = []
		hex_history.resize(steps)
		history.set_content(index, hex_history)
		
func make_history(step:int, index:HexIndex) -> Dictionary:
	return get_history(step, index)
	
func get_history(step:int, index:HexIndex) -> Dictionary:
	return history.get_content(index)[step]
