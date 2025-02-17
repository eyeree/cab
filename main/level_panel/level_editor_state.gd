class_name LevelEditorState extends Resource

const LEVEL_EDITOR_STATE_PATH := 'user://level_editor_state.tres'

@export var current_level_path:String = ''

static func load() -> LevelEditorState:
	if ResourceLoader.exists(LEVEL_EDITOR_STATE_PATH):
		return ResourceLoader.load(LEVEL_EDITOR_STATE_PATH)
	else:
		var state = LevelEditorState.new()
		state.resource_path = LEVEL_EDITOR_STATE_PATH
		return state

func save() -> void:
	ResourceSaver.save(self)
