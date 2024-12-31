class_name Gene extends Resource

static var _serialization = SerializationUtil.register(Gene) \
	.as_resource_path(Gene)

var name:String = "(new gene)"
var required_effects:Array[StringName] = []

func create_state(creator:Cell, config:GeneConfig) -> GeneState:
	return GeneState.new()
	
func create_config() -> GeneConfig:
	return GeneConfig.new()
	
