class_name WorldHistory extends RefCounted

var history:HexStore = HexStore.new()

func _init(radius:int, steps:int) -> void:
	for index in HexIndex.CENTER.spiral(radius):
		var hex_history:Array[Dictionary] = []
		hex_history.resize(steps + 1) # + 1 for initial state
		history.set_content(index, hex_history)

func get_history_entry(index:HexIndex, step:int) -> Dictionary:
	return history.get_content(index)[step]
	
func get_history(index:HexIndex) -> Array[Dictionary]:
	return history.get_content(index)
