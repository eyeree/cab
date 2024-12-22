extends Camera3D

@onready var grid_scene: Grid = $"../HBoxContainer/SubViewportContainer/SubViewport/GridScene"
@onready var sub_viewport_container: SubViewportContainer = $"../HBoxContainer/SubViewportContainer"

func _process(_delta:float) -> void:
		#prints('_ready', grid_scene.camera.get_global_position())
		var vpcp:Vector2 = sub_viewport_container.get_transform().get_origin()
		#var vp2 = sub_viewport_container.get_viewport()
		set_global_position(Vector3(vpcp.x, vpcp.y, grid_scene.camera_distance))
		prints('_ready', vpcp, get_global_position())
		pass
