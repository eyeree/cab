@tool
class_name GridScene extends Node3D

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
	var _hex_scale:float
	var _hex_radius:float
	var _hex_offset:float
	var _hex_power:float
	var _camera_position:Vector3
	var _hex_size:float
	var _min_x_index:int
	var _max_x_index:int
	var _min_y_index:int
	var _max_y_index:int

	func _init(
		hex_scale:float, 
		hex_radius:float, 
		hex_offset:float, 
		hex_power:float,
		camera_position:Vector3
	):
		_hex_scale = hex_scale
		_hex_radius = hex_radius
		_hex_offset = hex_offset
		_hex_power = hex_power
		_camera_position = camera_position
		_hex_size = (_hex_radius + _hex_offset) / _hex_scale

	func apply_grid_shader_settings(shader_material:ShaderMaterial) -> void:
		shader_material.set_shader_parameter('scale', _hex_scale)
		shader_material.set_shader_parameter('radius', _hex_radius)
		shader_material.set_shader_parameter('offset', _hex_offset)
		shader_material.set_shader_parameter('power', _hex_power)

	func apply_camera_settings(camera:Camera3D) -> void:
		camera.position = _camera_position
		
	var hex_size:float:
		get():
			return _hex_size
			
	func hex_center(hex_index:Vector2i) -> Vector2:
		var x = _hex_size * (_3_OVER_2 * hex_index.x)
		var y = _hex_size * (_SQRT_3_OVER_2 * hex_index.x + _SQRT_3 * hex_index.y)
		return Vector2(x, y)
		
	func hex_index(position:Vector2) -> Vector2i:
		var x = (_2_OVER_3 * position.x) / _hex_size
		var y = (_MINUS_1_OVER_3 * position.x  + _SQRT_3_OVER_3 * position.y) / _hex_size
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
	GridSize.SMALL: GridSizeInfo.new(5.0, 0.45, 0.05, 10.0, Vector3(0.0, 0.007, 0.55)),    # 5
	GridSize.MEDIUM: GridSizeInfo.new(9.5, 0.45, 0.05, 10.0, Vector3(0.0, 0.007, 0.58)),   # 10
	GridSize.LARGE: GridSizeInfo.new(13.5, 0.45, 0.05, 10.0, Vector3(0.0, 0.007, 0.61)),   # 15
	GridSize.HUGE: GridSizeInfo.new(18.0, 0.45, 0.05, 10.0, Vector3(0.0, 0.007, 0.61)),    # 20
}

@export var grid_size:GridSize = GridSize.SMALL:
	set(value):
		grid_size = value
		_grid_size_info = grid_size_info_map[value]
		_on_grid_size_set()

var _grid_size_info:GridSizeInfo = grid_size_info_map[grid_size]

@onready var grid_shader:ShaderMaterial = %GridPlane.mesh.material
@onready var camera:Camera3D = %Camera

func _ready() -> void:
	_on_grid_size_set()

func _on_grid_size_set():
	if not is_inside_tree(): return
	_grid_size_info.apply_grid_shader_settings(grid_shader)
	_grid_size_info.apply_camera_settings(camera)

func _mouse_position_to_grid_position(mouse_position:Vector2) -> Vector2:
	var drop_plane:Plane = Plane(Vector3(0, 0, 1), 0)
	var intersection_position:Vector3 = drop_plane.intersects_ray(camera.project_ray_origin(mouse_position), camera.project_ray_normal(mouse_position))
	var grid_position:Vector2 = Vector2(intersection_position.x, -intersection_position.y)
	return grid_position
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
	elif event is InputEventMouseMotion:
		var grid_position:Vector2 = _mouse_position_to_grid_position(event.position)
		var hex_index:Vector2i = _grid_size_info.hex_index(grid_position)
		var hex_center:Vector2 = _grid_size_info.hex_center(hex_index)
		prints('_input', event.position, '->', hex_index, hex_center)
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
