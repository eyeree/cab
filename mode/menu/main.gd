extends Control
@onready var battle_button: Button = %BattleButton

func _ready() -> void:
	GeneType.get_all_gene_types()
	
func _on_battle_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mode/battle/battle_mode.tscn")
