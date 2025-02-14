class_name HexGrid extends Node3D
	  
#region: External References

@onready var _grid_material:ShaderMaterial = %GridPlane.mesh.material
@onready var _grid_plane:MeshInstance3D = %GridPlane
@onready var _camera_control:CameraControl = %CameraControl

#endregion

#region: Initialization

func _ready() -> void:
	# setter is not called for props with default values
	# force updates to set shader parameters now that material is ready
	default_line_color = default_line_color
	default_background_color = default_background_color
	hex_background_colors = hex_background_colors
	hex_line_colors = hex_line_colors
	rings = rings
	
#endregion

#region: HexGrid Size

# percent of plane used, to leave a margin so there is room for outer lines
const plane_extent_percent:float = 0.9

var _hex_outer_radius:float
var hex_outer_radius:float:
	get: return _hex_outer_radius
	
var _hex_inner_radius:float
var hex_inner_radius:float:
	get: return _hex_inner_radius
	
var _content_scale:Vector3
var content_scale:Vector3:
	get: return _content_scale

@export var rings:int = 3:
	set(value): 
		rings = value
		_hex_outer_radius = (plane_extent_percent / ((rings*2+1) * sqrt(3.0))) # (1.0 - _line_size * 2) / ...
		_hex_inner_radius = (_hex_outer_radius * sqrt(3.0) / 2.0)
		_content_scale = Vector3(_hex_inner_radius, _hex_inner_radius, _hex_inner_radius) * 2
		if is_inside_tree():
			clear_all_hex_content()
			_grid_material.set_shader_parameter('max_hex_distance', rings)
			_grid_material.set_shader_parameter('hex_outer_radius', hex_outer_radius)	

#endregion
	
#region: Hex Content
  
var _hex_content:HexStore = HexStore.new()

func _add_content_to_tree(index:HexIndex, content:Node3D):
	var position2D:Vector2 = index.center_point(hex_outer_radius)
	content.position = Vector3(position2D.x, 0, position2D.y)
	content.scale = content_scale
	_grid_plane.add_child(content)

func _remove_content_from_tree(content:Node3D):
	_grid_plane.remove_child(content)
	content.queue_free()
	
func set_hex_content(index:HexIndex, content:Node3D) -> Node3D:
	var current:Node3D = _hex_content.get_content(index) as Node3D
	if current: _remove_content_from_tree(current)
	_hex_content.set_content(index, content)
	if content: _add_content_to_tree(index, content)
	return current
	
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		
		if _camera_control.ActualMouseState != CameraControl.E_MOUSE_ACTION_STATES.IDLE:
			return
			
		var hex_index = _get_mouse_hex_index()
		if hex_index != _mouse_hex_index:			
			if _mouse_hex_index != HexIndex.INVALID:
				mouse_exited_hex.emit(_mouse_hex_index)
			_mouse_hex_index = hex_index
			if _mouse_hex_index != HexIndex.INVALID:
				mouse_entered_hex.emit(_mouse_hex_index)

	elif Input.is_action_just_pressed("GridSelect"):
		var hex_index = _get_mouse_hex_index()
		hex_selected.emit(hex_index)
		
func _get_mouse_hex_index() -> HexIndex:
	var grid_position:Vector2 = _mouse_position_to_grid_plane_position()
	if grid_position == Vector2.INF: return HexIndex.INVALID
	var hex_index:HexIndex = HexIndex.from_point(grid_position, hex_outer_radius)
	if hex_index.distance_to_center() > rings: return HexIndex.INVALID
	return hex_index

# range of -0.5 to 0.5 over the grid plane adjusted for the plane_extent_percent
func _mouse_position_to_grid_plane_position() -> Vector2:
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

func get_center_point(index:HexIndex) -> Vector3:
	var center_point:Vector2 = index.center_point(hex_outer_radius)
	var local_point:Vector3 = Vector3(center_point.x, -center_point.y, 0)
	return to_global(local_point)
	
func point_to_index(global_point:Vector3) -> HexIndex:
	var local_point = to_local(global_point)
	var hex_index:HexIndex = HexIndex.from_point(Vector2(local_point.x, local_point.y), hex_outer_radius)
	if hex_index.distance_to_center() > rings: 
		return HexIndex.INVALID
	else:
		return hex_index
		
signal mouse_entered_hex(index:HexIndex)
signal mouse_exited_hex(index:HexIndex)
signal hex_selected(index:HexIndex)

#endregion

#region Hex Color

@export var default_line_color:Color = Color.WHITE:
	set(value):
		default_line_color = value
		if _grid_material:
			_grid_material.set_shader_parameter('default_line_color', value)	

@export var default_background_color:Color = Color.BLACK:
	set(value):
		default_background_color = value
		if _grid_material:
			_grid_material.set_shader_parameter('default_background_color', value)	

@export var outside_color:Color = Color.BLACK:
	set(value):
		outside_color = value
		if _grid_material:
			_grid_material.set_shader_parameter('outside_color', value)
			
@export var hex_line_colors:Array[Color] = []:
	set(value):
		hex_line_colors = value
		if _grid_material:
			_grid_material.set_shader_parameter('hex_line_colors', value)
			
@export var hex_background_colors:Array[Color] = []:
	set(value):
		hex_background_colors = value
		if _grid_material:
			_grid_material.set_shader_parameter('hex_background_colors', value)

var _hex_colors:Dictionary[HexIndex, int] = {}

func set_hex_color(index:HexIndex, color_index:int) -> void:
	_hex_colors[index] = color_index
	_set_hex_colors()

func set_hex_colors(indexes:Array[HexIndex], color_index:int) -> void:
	for index in indexes:
		_hex_colors[index] = color_index
	_set_hex_colors()

func clear_hex_color(index:HexIndex) -> void:
	_hex_colors.erase(index)
	_set_hex_colors()

func clear_hex_colors(indexes:Array[HexIndex]) -> void:
	for index in indexes:
		_hex_colors.erase(index)
	_set_hex_colors()

func clear_all_hex_colors() -> void:
	_hex_colors.clear()
	_set_hex_colors()
	
func _set_hex_colors() -> void:
	var packed_indexes:PackedInt32Array = []
	var color_indexes:PackedInt32Array = []
	for index:HexIndex in _hex_colors.keys():
		packed_indexes.append(index.q)
		packed_indexes.append(index.r)
		color_indexes.append(_hex_colors[index])
	_grid_material.set_shader_parameter('colored_hex_indexes', packed_indexes)
	_grid_material.set_shader_parameter('colored_hex_color_index', color_indexes)
	_grid_material.set_shader_parameter('colored_hex_count', _hex_colors.size())
	
#endregion
