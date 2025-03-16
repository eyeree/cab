class_name WorldState extends RefCounted

var world_state:HexStore = HexStore.new()

func _init(radius:int, steps:int) -> void:
	for index in HexIndex.CENTER.spiral(radius):
		var hex_state:Array[CellState] = []
		hex_state.resize(steps + 1) # + 1 for initial state
		#for i in range(steps+1):
			#hex_state[i] = CellState.new()
		world_state.set_content(index, hex_state)

func get_history_entry(index:HexIndex, step:int) -> CellState:
	var hex_state:Array[CellState] = world_state.get_content(index)
	var cell_state:CellState = hex_state[step]
	if cell_state == null:
		cell_state = CellState.new()
		hex_state[step] = cell_state
	return cell_state
	
func get_history(index:HexIndex) -> Array[CellState]:
	return world_state.get_content(index)
