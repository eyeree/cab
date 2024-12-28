# Copyright (c) 2024, Ludo Houben <ljlhouben@gmail.com>, 
# This work is licensed under CC BY-SA 4.0.
# To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/
#
# If you like my work than I would appreciate receiving a coffee
# https://www.buymeacoffee.com/ljlhouben
#
# VERSION: 1.0
# DESCRPTION:
#     This script operates a camera in a 'Transport Fever' way. And can be controlled by keys,
#     mouse and mousepad. Following features are implemented:
#     - Movement LEFT/DOWN/UP/RIGHT (keys: 'A/S/W/D' / mouse[pad]: left/down/up/right with right button)
#     - Rotate CCW/CW (keys: 'Q/E' / mouse[pad]: left/right with middle button [key 'CTRL'])
#     - Tilt UP/DOWN (keys: 'R/F' / mouse[pad]: up/down with middle button [key 'CTRL'])
#     - Zoom OUT/IN (keys: 'Z/X' / mouse[pad]: scroll up/down [2 point pinch/release])
#     - Interlocking of contradictional movements
#     - Optional edge scrolling LEFT/DOWN/UP/RIGHT and debug information
#     - Configurable speeds/initial positions/limits/inversion of movement direction
#
# INPUT MAPPING:
#     ui_up [key W] / ui_down [key S] / ui_left [key A] / ui_right [key D]
#     ui_zoom_in [key Z] / ui_zoom_out [key X]
#     ui_rotate_left [key Q] / ui_rotate_right [key E]
#     ui_tilt_forward [key R] / ui_tilt_backward [key F]
#     mouse_btn_left / mouse_btn_middle [key CTRL] / mouse_btn_right
#     mouse_wheel_up / mouse_wheel_down
#     NOTE: Couple the mouse buttons as 'all devices'
#
# MODEFICATION HISTORY:
#    v1.0: Initial version based on Godot v4.3

class_name CameraControl extends Node3D

enum E_MOUSE_ACTION_STATES {
	IDLE,
	MOVE_AND_DRAG,
	ROTATE_AND_TILT,
}

# Generic
@export_group('General', 'Cfg')
@export var CfgShowDebugInfo : bool = false
@export var CfgMaxDistanceFromOrigin : float = 0.5

# Zooming
@export_group('Zooming', 'CfgZoom')
@export var CfgZoomInvertDirection : bool = false
@export var CfgZoomSpeed : float = 1
@export var CfgZoomInitDistance : float = 10
@export var CfgZoomMaxIn : float = 5.0
@export var CfgZoomMaxOut : float = 100.0
@export var CfgZoomScrollFactor : float = 5.0

# Moving
@export_group('Moving', 'CfgMove')
@export var CfgMoveInvertDirectionX : bool = false
@export var CfgMoveInvertDirectionY : bool = false
@export var CfgMoveSpeed : float = 1
@export var CfgMoveInitPos : Vector2 = Vector2(0,5)
@export var CfgMoveEnableSideMoving : bool = true
@export var CfgMoveSideMovingThreshold : float = 20.0

# Rotation
@export_group('Rotation', 'CfgRotate')
@export var CfgRotateInvertDirection : bool = false
@export var CfgRotateSpeed : float = 1

# Tilting
@export_group('Tilting', 'CfgTilt')
@export var CfgTiltInvertDirection : bool = false
@export var CfgTiltSpeed : float = 1
@export var CfgTiltInitAngle : float = 25
@export var CfgTiltMinAngle : float = 5.0
@export var CfgTiltMaxAngle : float = 80.0

@export_group('Input', 'CfgInput')

@export_subgroup('Mouse', 'CfgInputMouse')
@export var CfgInputMouseSensitivity : float = 1.0
@export var CfgInputMouseMove : String = "mouse_btn_right"
@export var CfgInputMouseRotateAndTilt : String = "mouse_btn_middle"
@export var CfgInputMouseZoomIn : String = "mouse_wheel_up"
@export var CfgInputMouseZoomOut : String = "mouse_wheel_down"

@export_subgroup('Keyboard', 'CfgInputKey')
@export var CfgInputKeyUp : String = "ui_up"
@export var CfgInputKeyLeft : String = "ui_left"
@export var CfgInputKeyDown : String = "ui_down"
@export var CfgInputKeyRight : String = "ui_right"
@export var CfgInputKeyZoomIn : String = "ui_zoom_in"
@export var CfgInputKeyZoomOut : String = "ui_zoom_out"
@export var CfgInputKeyRotateLeft : String = "ui_rotate_left"
@export var CfgInputKeyRotateRight : String = "ui_rotate_right"
@export var CfgInputKeyTiltForward : String = "ui_tilt_forward"
@export var CfgInputKeyTiltBackward : String = "ui_tilt_backward"

@export var CfgInputKeyReset : String = "ui_reset"

var ActualMouseState : E_MOUSE_ACTION_STATES = E_MOUSE_ACTION_STATES.IDLE
var ActualZoomDistance : float
var ActualZoomSpeed : float
var ActualMoveSpeed : float
var ActualRotateSpeed : float
var ActualTiltSpeed : float
var ActualTiltAngle : float

var RotationDirection : float = 1.0

func _ready():
	_reset()

func _reset():
	set_identity()
	global_position = Vector3(0, 0, 0)
	ActualZoomDistance = CfgZoomInitDistance
	ActualTiltAngle = CfgTiltInitAngle
	ActualZoomSpeed = 0.0
	ActualMoveSpeed = 0.0
	ActualRotateSpeed = 0.0
	ActualTiltSpeed = 0.0
	ActualMouseState = E_MOUSE_ACTION_STATES.IDLE
	$Camera.set_identity()
	$Camera.rotation.x = -deg_to_rad(ActualTiltAngle)
	$Camera.position = Vector3(CfgMoveInitPos.x, CfgMoveInitPos.y, ActualZoomDistance)
	$Camera.position = Vector3($Camera.position.x, -(ActualZoomDistance * sin($Camera.rotation.x)), (ActualZoomDistance * cos($Camera.rotation.x)))

func _process(delta):
	var viewPortSize = get_viewport().size
	var mousePos = get_viewport().get_mouse_position()

	var previous_position = Vector3(global_position)

	if Input.is_action_just_released(CfgInputKeyReset):
		_reset()
	
# Mouse action state handling
	if Input.is_action_just_pressed(CfgInputMouseMove):
		ActualMouseState = E_MOUSE_ACTION_STATES.MOVE_AND_DRAG
	elif Input.is_action_just_pressed(CfgInputMouseRotateAndTilt):
		ActualMouseState = E_MOUSE_ACTION_STATES.ROTATE_AND_TILT
		if (mousePos.y < viewPortSize.y / 2.0):
			RotationDirection = -1.0
		else:
			RotationDirection = 1.0
	elif Input.is_action_just_released(CfgInputMouseRotateAndTilt) or Input.is_action_just_released(CfgInputMouseMove):
		ActualMouseState = E_MOUSE_ACTION_STATES.IDLE
	
# Zoom handling
	ActualZoomSpeed = CfgZoomSpeed * 10 * (ActualZoomDistance / CfgZoomMaxIn) * delta
	if  CfgZoomInvertDirection:
		ActualZoomSpeed = ActualZoomSpeed * -1
	
	if Input.is_action_just_released(CfgInputMouseZoomIn) and not Input.is_action_pressed(CfgInputKeyZoomOut):
		ActualZoomDistance -= ActualZoomSpeed * CfgZoomScrollFactor
	
	if Input.is_action_pressed(CfgInputKeyZoomIn) \
			and not (Input.is_action_pressed(CfgInputKeyZoomOut) or Input.is_action_just_released(CfgInputMouseZoomOut)):
		ActualZoomDistance -= ActualZoomSpeed
	
	if Input.is_action_just_released(CfgInputMouseZoomOut) and not Input.is_action_pressed(CfgInputKeyZoomIn):
		ActualZoomDistance += ActualZoomSpeed * CfgZoomScrollFactor
	
	if Input.is_action_pressed(CfgInputKeyZoomOut) \
			and not (Input.is_action_pressed(CfgInputKeyZoomIn) or Input.is_action_just_released(CfgInputMouseZoomIn)):
		ActualZoomDistance += ActualZoomSpeed
	ActualZoomDistance = clamp(ActualZoomDistance, CfgZoomMaxIn, CfgZoomMaxOut)
	
# Move handling
	ActualMoveSpeed = -CfgMoveSpeed * 10 * ((ActualZoomDistance * CfgZoomMaxOut) / (CfgZoomMaxIn * CfgZoomMaxOut)) * delta
	var HorzMoveDelta = KeyAndMouseCtrl(ActualMoveSpeed, CfgInputKeyLeft, CfgInputKeyRight, CfgMoveInvertDirectionX, \
										ActualMouseState == E_MOUSE_ACTION_STATES.MOVE_AND_DRAG, \
										(0.0025 * CfgInputMouseSensitivity)).Xvalue
	
	var VertMoveDelta = KeyAndMouseCtrl(ActualMoveSpeed, CfgInputKeyUp, CfgInputKeyDown, CfgMoveInvertDirectionY, \
										ActualMouseState == E_MOUSE_ACTION_STATES.MOVE_AND_DRAG, \
										(0.0025 * CfgInputMouseSensitivity)).Yvalue

	global_position.x -= cos(rotation.y) * HorzMoveDelta
	global_position.y -= sin(rotation.y) * HorzMoveDelta
	global_position.x += sin(rotation.y) * VertMoveDelta
	global_position.y -= cos(rotation.y) * VertMoveDelta
	
# Edge scrolling
	if CfgMoveEnableSideMoving and ActualMouseState == E_MOUSE_ACTION_STATES.IDLE \
			and not (Input.is_action_pressed(CfgInputKeyUp) or Input.is_action_pressed(CfgInputKeyDown) \
				or Input.is_action_pressed(CfgInputKeyLeft) or Input.is_action_pressed(CfgInputKeyRight)):
		if mousePos.x >= 0 and mousePos.x <= CfgMoveSideMovingThreshold:
			global_position.x += ActualMoveSpeed * cos(rotation.y)
			global_position.z -= ActualMoveSpeed * sin(rotation.y)
		
		if mousePos.x >= (viewPortSize.x - CfgMoveSideMovingThreshold) and mousePos.x <= viewPortSize.x:
			global_position.x -= ActualMoveSpeed * cos(rotation.y)
			global_position.z += ActualMoveSpeed * sin(rotation.y)
		
		if mousePos.y >= 0 and mousePos.y <= CfgMoveSideMovingThreshold:
			global_position.x += ActualMoveSpeed * sin(rotation.y)
			global_position.z += ActualMoveSpeed * cos(rotation.y)
		
		if mousePos.y >= (viewPortSize.y - CfgMoveSideMovingThreshold)and mousePos.y <= viewPortSize.y:
			global_position.x -= ActualMoveSpeed * sin(rotation.y)
			global_position.z -= ActualMoveSpeed * cos(rotation.y)
	
# Rotate handling
	ActualRotateSpeed = CfgRotateSpeed * 1.5 * delta
	var actualRotation = KeyAndMouseCtrl(ActualRotateSpeed,CfgInputKeyRotateLeft, CfgInputKeyRotateRight, CfgRotateInvertDirection, \
										ActualMouseState == E_MOUSE_ACTION_STATES.ROTATE_AND_TILT, \
										(0.0025 * CfgInputMouseSensitivity)).Xvalue
	actualRotation *= RotationDirection
	rotate_y(actualRotation)
	
# Tilt handling
	ActualTiltSpeed = CfgTiltSpeed * 100 * delta
	ActualTiltAngle += (KeyAndMouseCtrl(ActualTiltSpeed, CfgInputKeyTiltForward, CfgInputKeyTiltBackward, CfgTiltInvertDirection, \
										ActualMouseState == E_MOUSE_ACTION_STATES.ROTATE_AND_TILT, \
										(0.0025 * CfgInputMouseSensitivity)).Yvalue)
	ActualTiltAngle = clamp(ActualTiltAngle, CfgTiltMinAngle, CfgTiltMaxAngle)
	$Camera.rotation.x = -deg_to_rad(ActualTiltAngle)
	# $Camera.rotation.x = -deg_to_rad(ActualTiltAngle + (((CfgTiltMaxAngle - CfgTiltMinAngle)/2) * (ActualZoomDistance/CfgZoomMaxOut)))
	
# Update camera position
	$Camera.position = Vector3($Camera.position.x, -(ActualZoomDistance * sin($Camera.rotation.x)), (ActualZoomDistance * cos($Camera.rotation.x)))

	var center:Vector2i = viewPortSize / 2;
	var origin = $Camera.project_ray_origin(center)
	var direction = $Camera.project_ray_normal(center);
	var plane = Plane(Vector3.FORWARD, 0)
	var intersection = plane.intersects_ray(origin, direction)
	if intersection and intersection.length() > CfgMaxDistanceFromOrigin:
		global_position = previous_position

	
# Debug info
	$DebugInfo.text = "FPS: " + str(Engine.get_frames_per_second()) \
					+ "\n" + "Actual move speed: " + str(abs(ActualMoveSpeed)) \
					+ "\n" + "Actual zoom distance: " + str(abs(ActualZoomDistance)) \
					+ "\n" + "Global position: " + str(global_position) \
					+ "\n" + "Relative position: " + str(position) \
					+ "\n" + "Actual rotate angle: " + str(rad_to_deg(rotation.y)) \
					+ "\n" + "Actual tilt angle: " + str(ActualTiltAngle) \
					+ "\n" + "Actual camera angle: " + str(rad_to_deg($Camera.rotation.x)) \
					+ "\n" + "Mouse rotate and tilt clicked: " + str(Input.is_action_pressed(CfgInputMouseRotateAndTilt)) \
					+ "\n" + "Mouse move clicked: " + str(Input.is_action_pressed(CfgInputMouseMove)) \
					+ "\n" + "Intersection: " + str(intersection) \
					+ "\n" + "Intersection Length: " + str(intersection.length())
	$DebugInfo.visible = CfgShowDebugInfo

func KeyAndMouseCtrl(Value : float, KeyNegative : String, KeyPositive : String, InvertDirection : bool, MouseActive : bool, MouseSensitivity : float):
	var Status = {"Xvalue" : 0.0, "Yvalue" : 0.0}
	
	if MouseActive and InputEventMouseMotion \
			and not (Input.is_action_pressed(KeyNegative) or Input.is_action_pressed(KeyPositive)):
		Status.Xvalue = Value * Input.get_last_mouse_velocity().x * MouseSensitivity
		Status.Yvalue = Value * Input.get_last_mouse_velocity().y * MouseSensitivity
	
	if Input.is_action_pressed(KeyNegative) and not (MouseActive or Input.is_action_pressed(KeyPositive)):
		Status.Xvalue = -Value
		Status.Yvalue = -Value
	
	if Input.is_action_pressed(KeyPositive) and not (MouseActive or Input.is_action_pressed(KeyNegative)):
		Status.Xvalue = Value
		Status.Yvalue = Value
	
	if InvertDirection:
		Status.Xvalue = -Status.Xvalue
		Status.Yvalue = -Status.Yvalue
	
	return Status
