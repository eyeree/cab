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
@onready var camera:Camera3D = %Camera

func _ready() -> void:
	_on_grid_size_set()

func _on_grid_size_set():
	prints('_on_grid_size_set')
	if not is_inside_tree(): return
	_grid_size_info.apply_grid_material_settings(grid_material)
	
func set_selected_index(index:Vector2i) -> void:
	grid_material.set_shader_parameter('selected_index', index)
	
func clear_selected_index(index:Vector2i) -> void:
	grid_material.set_shader_parameter('selected_index', Vector2i(1000, 1000))

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
		set_selected_index(hex_index)
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
