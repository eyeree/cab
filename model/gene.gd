class_name Gene extends Resource

static func _static_init():
	SerializationUtil.register(Gene) \
		.use_resource_path_for(Gene)

var name:String = "(new gene)"
var required_effects:Array[StringName] = []

func create_state(progenitor:Cell, config:GeneConfig) -> GeneState:
	return GeneState.new()
	
func create_config() -> GeneConfig:
	return GeneConfig.new()
	
