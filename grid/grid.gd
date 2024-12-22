@tool
class_name Grid extends Node3D

# https://www.redblobgames.com/grids/hexagons/

const _3_OVER_2:float = 3.0 / 2.0
const _2_OVER_3:float = 2.0 / 3.0
const _MINUS_1_OVER_3:float = -1.0 / 3.0
const _SQRT_3:float = sqrt(3)
const _SQRT_3_OVER_2:float = _SQRT_3 / 2.0
const _SQRT_3_OVER_3:float = _SQRT_3 / 3.0

const INVALID_HEX_INDEX:Vector2i = Vector2i.MAX

enum GridSize { SMALL, MEDIUM, LARGE, HUGE }

class GridSizeInfo:
	var _hex_max_distance:int
	var _hex_size:float
	var _line_size:float

	func _init(
		hex_max_distance:int,
		line_size:float
	):
		_line_size = line_size
		_hex_max_distance = hex_max_distance
		_hex_size = (1.0 / ((_hex_max_distance*2+1) * sqrt(3))) # (1.0 - _line_size * 2) / ...

	func apply_grid_material_settings(grid_material:ShaderMaterial) -> void:
		grid_material.set_shader_parameter('max_hex_distance', _hex_max_distance)
		grid_material.set_shader_parameter('line_size', _line_size)

	var hex_size:float:
		get():
			return _hex_size
			
	func hex_center(index:Vector2i) -> Vector2:
		# pointy_hex_to_pixel https://www.redblobgames.com/grids/hexagons/#hex-to-pixel-axial
		var x:float = _hex_size * (sqrt(3) * index.x  +  sqrt(3)/2 * index.y)
		var y:float = _hex_size * (3.0/2.0 * index.y)
		return Vector2(x, y)
		
	func hex_index(point:Vector2) -> Vector2i:
		# pixel_to_pointy_hex https://www.redblobgames.com/grids/hexagons/#pixel-to-hex	
		var x:float = (sqrt(3)/3 * point.x  -  1.0/3.0 * point.y) / _hex_size
		var y:float = (2.0/3.0 * point.y) / _hex_size
		return _axial_round(x, y)
		
	func _axial_round(x:float, y:float) -> Vector2i:
		var x_grid:int = roundi(x)
		var y_grid:int = roundi(y)
		x -= x_grid
		y -= y_grid
		if abs(x) >= abs(y):
			return Vector2i(x_grid + roundi(x + 0.5 * y), y_grid)
		else:
			return Vector2i(x_grid, y_grid + roundi(y + 0.5 * x))
					
static var grid_size_info_map: Dictionary[GridSize, GridSizeInfo] = {
	GridSize.SMALL: GridSizeInfo.new(2, 0.075),
	GridSize.MEDIUM: GridSizeInfo.new(4, 0.125),
	GridSize.LARGE: GridSizeInfo.new(7, 0.15),
	GridSize.HUGE: GridSizeInfo.new(10, 0.175),
}

@export var grid_size:GridSize = GridSize.SMALL:
	set(value):
		grid_size = value
		_grid_size_info = grid_size_info_map[value]
		_on_grid_size_set()

var _grid_size_info:GridSizeInfo = grid_size_info_map[grid_size]

@onready var grid_material:ShaderMaterial = %GridPlane.mesh.material
@onready var grid_plane:MeshInstance3D = %GridPlane
@onready var camera: Camera3D = $"../../../../Camera3D"

var camera_distance:float = 0.0

func _ready() -> void:
	_sync_camera_positions()
	_on_grid_size_set()

func _on_grid_size_set():
	prints('_on_grid_size_set')
	if not is_inside_tree(): return
	_grid_size_info.apply_grid_material_settings(grid_material)
	
func set_selected_index(index:Vector2i) -> void:
	grid_material.set_shader_parameter('selected_index', index)
	
func clear_selected_index() -> void:
	grid_material.set_shader_parameter('selected_index', Vector2i.MAX)

func _sync_camera_positions():
	var vp1 = get_viewport()
	var c1 = vp1.get_camera_3d()
	var fov:float = c1.fov
	var max_extent:float =  grid_plane.get_aabb().get_longest_axis_size()
	camera_distance = max_extent / sin(deg_to_rad(fov / 2.0)) - 1.0
	var new_position = grid_plane.position + Vector3(0, 0, camera_distance)
	c1.position = new_position
	
func _focus_camera_on_node(camera: Camera3D, node: MeshInstance3D) -> void:
	var fov:float = camera.fov
	var max_extent:float =  node.get_aabb().get_longest_axis_size()
	var min_distance:float = max_extent / sin(deg_to_rad(fov / 2.0)) - 1.0
	#camera.look_at(node.translation, Vector3.UP)
	#var offset = (camera.position - node.position).normalized()
	#camera.position = node.position + (offset * min_distance)
	var new_position = node.position + Vector3(0, 0, min_distance)
	prints('_focus_camera_on_node', fov, max_extent, min_distance, camera.position, new_position)
	camera.position = new_position
	
# range of -0.5 to 0.5 over the viewport, adjusted for camera positioning relative # 
func _mouse_position_to_grid_position() -> Vector2:
	# (-0.818482, -0.467396)
	# (0.818482, 0.453396)

	#mouse_position = get_viewport().size
	#var grid_position:Vector2 = (mouse_position / Vector2(get_viewport().size)) - Vector2(0.5, 0.5)
	#grid_position -= Vector2(0, 0.007)
	#grid_position *= Vector2(float(get_viewport().size.x) / float(get_viewport().size.y), 1.0)
	#grid_position *= Vector2(1.2, 1.0)
	
	var vp2 = get_viewport()
	var c1:Camera3D = vp2.get_camera_3d()
	if vp2 is SubViewport:
		var vpc:SubViewportContainer = get_parent().get_parent()
		var vpcp:Vector2 = vpc.get_global_position()	
		vp2 = get_parent().get_parent().get_viewport()
		prints('global_position', vpcp, c1.position, c1.global_position)
	var mp2 = vp2.get_mouse_position()
	var c2:Camera3D = vp2.get_camera_3d()
	#prints('global_position', c2.global_position, c1.global_position)
	var origin:Vector3 = c2.project_ray_origin(mp2) 
	var normal:Vector3 = c2.project_ray_normal(mp2)
	var end = origin + normal * 100
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var space_state:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	if not result.has('position'):
		return Vector2.INF	
		
	var hit_position:Vector3 = result['position']
		
	#prints('result', position)	

	#var drop_plane:Plane = Plane(Vector3(0, 0, 1), 0)
	#var intersection_position:Vector3 = drop_plane.intersects_ray(origin, normal)
	#var grid_position_2:Vector2 = Vector2(intersection_position.x, -intersection_position.y)
			
	#prints('_mouse_position_to_grid_position', mouse_position, mp2, grid_position, grid_position_2)
	return Vector2(hit_position.x, -hit_position.y)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
	elif event is InputEventMouseMotion:
		var grid_position:Vector2 = _mouse_position_to_grid_position()
		if grid_position != Vector2.INF:
			var hex_index:Vector2i = _grid_size_info.hex_index(grid_position)
			set_selected_index(hex_index)
			#var hex_center:Vector2 = _grid_size_info.hex_center(hex_index)
			#prints('_input', event.position, '->', grid_position, '->', hex_index, hex_center)
		else:
			clear_selected_index()
	elif event is InputEventKey:
		var key_event:InputEventKey = event
		var just_pressed = key_event.is_pressed() and not key_event.is_echo()
		if just_pressed:
			match key_event.keycode:
				KEY_1:
					grid_size = GridSize.SMALL
				KEY_2:
					grid_size = GridSize.MEDIUM
				KEY_3:
					grid_size = GridSize.LARGE
				KEY_4:
					grid_size = GridSize.HUGE
