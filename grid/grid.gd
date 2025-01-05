class_name Grid extends Node3D
	  
#region: External References

@onready var _grid_material:ShaderMaterial = %GridPlane.mesh.material
@onready var _grid_plane:MeshInstance3D = %GridPlane
@onready var _camera_control:CameraControl = %CameraControl

#endregion

#region: Initialization

func _ready() -> void:
	_on_grid_size_set()
	set_selected_index(HexIndex.INVALID)
	clear_highlighted_indexes()
	
#endregion

#region: Grid Size

enum GridSize { SMALL, MEDIUM, LARGE, HUGE }

class GridSizeInfo:
	var hex_max_distance:int
	var hex_outer_radius:float
	var hex_inner_radius:float
	var content_scale:Vector3
	var line_size:float

	func _init(
		hex_max_distance_:int,
		line_size_:float
	):
		line_size = line_size_
		hex_max_distance = hex_max_distance_
		hex_outer_radius = (1.0 / ((hex_max_distance*2+1) * sqrt(3.0))) # (1.0 - _line_size * 2) / ...
		hex_inner_radius = (hex_outer_radius * sqrt(3.0) / 2.0)
		content_scale = Vector3(hex_inner_radius, hex_inner_radius, hex_inner_radius) * 2

	func apply_grid_material_settings(grid_material:ShaderMaterial) -> void:
		grid_material.set_shader_parameter('max_hex_distance', hex_max_distance)
		grid_material.set_shader_parameter('hex_outer_radius', hex_outer_radius)
		grid_material.set_shader_parameter('line_size', line_size)
			
static var _grid_size_info_map: Dictionary[GridSize, GridSizeInfo] = {
	GridSize.SMALL: GridSizeInfo.new(5, 0.13),
	GridSize.MEDIUM: GridSizeInfo.new(10, 0.17),
	GridSize.LARGE: GridSizeInfo.new(20, 0.21),
	GridSize.HUGE: GridSizeInfo.new(40, 0.30),
}

@export var grid_size:GridSize = GridSize.SMALL:
	set(value):
		grid_size = value
		_grid_size_info = _grid_size_info_map[value]
		_on_grid_size_set()

var _grid_size_info:GridSizeInfo = _grid_size_info_map[grid_size]

var rings:int:
	get: return _grid_size_info.hex_max_distance

func _on_grid_size_set():
	if not is_inside_tree(): return
	clear_all_hex_content()
	_grid_size_info.apply_grid_material_settings(_grid_material)

#endregion
	
#region: Hex State

func set_selected_index(index:HexIndex) -> void:
	_grid_material.set_shader_parameter('selected_index', index.to_axial())
	
func clear_selected_index() -> void:
	_grid_material.set_shader_parameter('selected_index', HexIndex.INVALID.to_axial())

func set_highlighted_indexes(indexes:Array[HexIndex]) -> void:
	var packed_indexes:PackedInt32Array = []
	for index:HexIndex in indexes:
		packed_indexes.append(index.q)
		packed_indexes.append(index.r)
	_grid_material.set_shader_parameter('highlighted_indexes', packed_indexes)
	_grid_material.set_shader_parameter('highlighted_index_count', indexes.size())
	
func clear_highlighted_indexes() -> void:
	_grid_material.set_shader_parameter('highlighted_index_count', 0)
	_grid_material.set_shader_parameter('highlighted_indexes', null)

#endregion
  
#region: Hex Content
  
var _hex_content:HexStore = HexStore.new()

func _add_content_to_tree(index:HexIndex, content:Node3D):
	var position2D:Vector2 = index.center_point(_grid_size_info.hex_outer_radius)
	content.position = Vector3(position2D.x, 0, position2D.y)
	content.scale = _grid_size_info.content_scale
	_grid_plane.add_child(content)

func _remove_content_from_tree(content:Node3D):
	_grid_plane.remove_child(content)
	content.queue_free()
	
func set_hex_content(index:HexIndex, content:Node3D):
	var current:Node3D = _hex_content.get_content(index) as Node3D
	if current: _remove_content_from_tree(current)
	_hex_content.set_content(index, content)
	if content: _add_content_to_tree(index, content)
	
func clear_hex_content(index:HexIndex):
	set_hex_content(index, null)

func get_hex_content(index:HexIndex) -> Node3D:	
	return _hex_content.get_content(index) as Node3D
	
func clear_all_hex_content() -> void:
	for content:Node3D in _hex_content.get_all_content():
		_remove_content_from_tree(content)
	_hex_content.clear_all_content()
	
#endregion

#region: Mouse Position
	
var _mouse_hex_index:HexIndex = HexIndex.INVALID

# range of -0.5 to 0.5 over the viewport, adjusted for camera positioning relative # 
func _mouse_position_to_grid_position() -> Vector2:
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var camera:Camera3D = viewport.get_camera_3d()
	var origin:Vector3 = camera.project_ray_origin(mouse_position) 
	var normal:Vector3 = camera.project_ray_normal(mouse_position)
	var end = origin + normal * 100
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var space_state:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	if not result.has('position'):
		return Vector2.INF	
	else:	
		var hit_position:Vector3 = result['position']
		return Vector2(hit_position.x, -hit_position.y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		
		if _camera_control.ActualMouseState != CameraControl.E_MOUSE_ACTION_STATES.IDLE:
			return

		var grid_position:Vector2 = _mouse_position_to_grid_position()
		if grid_position != Vector2.INF:
			var hex_index:HexIndex = HexIndex.from_point(grid_position, _grid_size_info.hex_outer_radius)
			if hex_index != _mouse_hex_index:
				if hex_index != null:
					mouse_exited_hex.emit(hex_index)
				if hex_index.distance_to_center() <= _grid_size_info.hex_max_distance:                   
					_mouse_hex_index = hex_index
					mouse_entered_hex.emit(hex_index)

	if event is InputEventKey:
		if event.keycode == KEY_Z and event.pressed and not event.echo:
			match grid_size:
				GridSize.SMALL:
					grid_size = GridSize.MEDIUM
				GridSize.MEDIUM:
					grid_size = GridSize.LARGE
				GridSize.LARGE:
					grid_size = GridSize.HUGE
				GridSize.HUGE:
					grid_size = GridSize.SMALL
		
signal mouse_entered_hex(index:HexIndex)
signal mouse_exited_hex(index:HexIndex)

#endregion
