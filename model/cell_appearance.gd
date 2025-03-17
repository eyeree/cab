class_name CellAppearance extends Node3D

var visible_connect_mesh:Node3D = null
var cell_type:CellType = null

func set_state(cell_history:CellState) -> void:
	var direction_label := HexIndex.DIRECTION_LABEL[HexIndex.opposite_direction(cell_history.cell.orientation)]
	var connect_mesh_name := "Connect" + direction_label
	if visible_connect_mesh != null and visible_connect_mesh.name == connect_mesh_name:
		return
	if visible_connect_mesh != null:
		visible_connect_mesh.visible = false
		visible_connect_mesh = null
	var connect_mesh := find_child("Connect" + direction_label, true)
	if connect_mesh is Node3D:
		connect_mesh.visible = true
		visible_connect_mesh = connect_mesh
	
func clone() -> CellAppearance:
	return duplicate(DuplicateFlags.DUPLICATE_USE_INSTANTIATION)

func get_grid() -> HexGrid:
	var parent:Node3D = get_parent_node_3d()
	while parent != null:
		if parent is HexGrid:
			return parent
		parent = parent.get_parent_node_3d()
	return null
	
var _orientation_indicator:Node3D = null

func show_orientation(orientation:HexIndex.HexDirection) -> void:
	prints('show_orientation', orientation)
	if _orientation_indicator == null:
		_orientation_indicator = preload("res://appearance/orientation_indicator.tscn").instantiate()
		add_child.call_deferred(_orientation_indicator)
	_orientation_indicator.rotation_degrees = Vector3(0, -60 * orientation, 0)
	_orientation_indicator.visible = true
	
func hide_orientation():
	prints('hide_orientation')
	if _orientation_indicator:
		_orientation_indicator.visible = false
