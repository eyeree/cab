@tool
class_name GridScene extends Node3D

enum GridSize { SMALL, MEDIUM, LARGE, HUGE }

class GridSizeInfo:
    var hex_scale:float
    var hex_radius:float
    var hex_offset:float
    var hex_power:float
    var camera_position:Vector3

    func _init(
        _hex_scale:float, 
        _hex_radius:float, 
        _hex_offset:float, 
        _hex_power:float,
        _camera_position:Vector3
    ):
        hex_scale = _hex_scale
        hex_radius = _hex_radius
        hex_offset = _hex_offset
        hex_power = _hex_power
        camera_position = _camera_position

    func apply_grid_shader_settings(shader_material:ShaderMaterial) -> void:
        shader_material.set_shader_parameter('scale', hex_scale)
        shader_material.set_shader_parameter('radius', hex_radius)
        shader_material.set_shader_parameter('offset', hex_offset)
        shader_material.set_shader_parameter('power', hex_power)

    func apply_camera_settings(camera:Camera3D) -> void:
        camera.position = camera_position

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

@onready var grid_plane:MeshInstance3D = %GridPlane
@onready var grid_shader:ShaderMaterial = %GridPlane.mesh.material
@onready var camera:Camera3D = %Camera

func _ready() -> void:
    _on_grid_size_set()

func _on_grid_size_set():
    _grid_size_info.apply_grid_shader_settings(grid_shader)
    _grid_size_info.apply_camera_settings(camera)


func _input(event: InputEvent) -> void:
    if event is InputEventKey:
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