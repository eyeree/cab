class_name GridCameraRig extends Node3D

var camera:Camera3D

@export var initial_rotation:Vector3 = Vector3.ZERO
@export var initial_position:Vector3 = Vector3(0, 0, 0.6)

@export var min_distance:float = 0.05
@export var max_distance:float = 0.6

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
	camera.position = initial_position
	camera.rotation = initial_rotation

enum MouseMovementMode { None, Rotate, Move }
var _mouse_movement_mode:MouseMovementMode = MouseMovementMode.None

func _input(event:InputEvent) -> void:
	
	if event.is_action_pressed("GridCameraZoomIn"):
		_zoom_in()
	elif event.is_action_pressed("GridCameraZoomOut"):
		_zoom_out()
	elif event.is_action_pressed("GridCameraRotate"):
		_mouse_movement_mode = MouseMovementMode.Rotate
	elif event.is_action_released("GridCameraRotate"):
		_mouse_movement_mode = MouseMovementMode.None
	elif event.is_action_pressed("GridCameraMove"):
		_mouse_movement_mode = MouseMovementMode.Move
	elif event.is_action_released("GridCameraMove"):
		_mouse_movement_mode = MouseMovementMode.None

	if event is InputEventMouseMotion:
		match _mouse_movement_mode:
			MouseMovementMode.Rotate:
				_rotate(event.relative)
			MouseMovementMode.Move:
				_move(event.relative)
				
	
func _zoom_in():
	pass
	
func _zoom_out():
	pass
	
func _rotate(amount:Vector3):
	pass
	
func _move(amount:Vector3):
	pass
		
			
#func _process(delta:float) -> void:
	#rotate_z( (PI/4) * delta )
