class_name GridCameraRig extends Node3D

var camera:Camera3D

@onready var grid_plane: MeshInstance3D = %GridPlane

@export var initial_rotation:Vector3 = Vector3.ZERO

@export var initial_distance:float = 0.6
@export var min_distance:float = 0.1
@export var max_distance:float = 1000
@export var zoom_speed:float = 2.0

var _distance: float = initial_distance
var _distance_delta: float = 0

@export var move_speed: float = 0.5

var _last_grid_position: Vector3

func _ready():
	camera = _find_camera()
	reset()
	
func _find_camera() -> Camera3D:
	for node in get_children():
		if node is Camera3D:
			return node
	push_error("No Camera3D child found in CameraRig.")
	return null

func reset():
	_distance = initial_distance
	position = Vector3.ZERO
	rotation = Vector3.ZERO

enum MouseMovementMode { None, Rotate, Move }
var _mouse_movement_mode:MouseMovementMode = MouseMovementMode.None

func _input(event:InputEvent) -> void:
	
	if event.is_action_pressed("GridCameraReset"):
		reset()
	elif event.is_action_pressed("GridCameraZoomIn"):
		_zoom_in()
	elif event.is_action_pressed("GridCameraZoomOut"):
		_zoom_out()
	#elif event.is_action_pressed("GridCameraRotate"):
		#_mouse_movement_mode = MouseMovementMode.Rotate
	#elif event.is_action_released("GridCameraRotate"):
		#_mouse_movement_mode = MouseMovementMode.None
	#elif event.is_action_pressed("GridCameraMove"):
		#_on_move_start(event.position)
	#elif event.is_action_released("GridCameraMove"):
		#_mouse_movement_mode = MouseMovementMode.None
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_on_move_start(event.position)
			else:
				_on_move_end()

	if event is InputEventMouseMotion:
		match _mouse_movement_mode:
			MouseMovementMode.Rotate:
				_rotate(event.relative)
			MouseMovementMode.Move:
				_on_move(event.position)
				
func _zoom_in():
	_distance_delta = -1 * zoom_speed
	
func _zoom_out():
	_distance_delta = 1 * zoom_speed
	
func _rotate(_amount:Vector2):
	pass
	
func _on_move_start(mouse_position:Vector2) -> void:
	_last_grid_position = _get_grid_position(mouse_position)
	_mouse_movement_mode = MouseMovementMode.Move
	
func _on_move_end() -> void:
	_mouse_movement_mode = MouseMovementMode.None
	
func _on_move(mouse_position:Vector2):
	var new_grid_position:Vector3 = _get_grid_position(mouse_position)
	if new_grid_position != Vector3.INF and _last_grid_position != Vector3.INF:
		var delta_grid_position:Vector3 = (_last_grid_position - new_grid_position)
		var p = self.position
		p.x += delta_grid_position.x
		self.set_identity()
		self.position = p
	_last_grid_position = new_grid_position

func _get_grid_position(mouse_position:Vector2) -> Vector3:
	var origin:Vector3 = camera.project_ray_origin(mouse_position) 
	var normal:Vector3 = camera.project_ray_normal(mouse_position)
	var plane := Plane(Vector3.BACK, 0)
	var intersection:Vector3 = plane.intersects_ray(origin, normal)

	var end = origin + normal * 100
	var ray_dir = (origin - end).normalized()
	var angle = abs(ray_dir.dot(Vector3.BACK))
	
	if intersection != null:
		return intersection  
	
	return Vector3.INF  
	
