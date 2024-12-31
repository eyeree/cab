class_name Gene extends Resource

#static var _instance_map:Dictionary[StringName, Gene] = {}
#
#static func get_instance(script_or_path:Variant) -> Gene:
	#var resource_path:StringName = script_or_path.resource_path \
		#if script_or_path is Script else script_or_path
	#var instance:Gene = _instance_map.get(resource_path)
	#if not instance:
		#var script:Script = script_or_path \
			#if script_or_path is Script else load(resource_path)
		#instance = script.new()
		#_instance_map.set(resource_path, instance)
	#return instance

var name:String = "(new gene)"
var required_effects:Array[StringName] = []

#region Serialization

static var _serialization = SerializationUtil.register(Gene)

static func deserialize(data:Dictionary) -> Gene:
	return load(data['resource_path']).instantiate()
	
func serialize() -> Dictionary:
	return { 'resource_path': resource_path	}

#endregion	
	
func deserialize_config(data:Variant) -> GeneConfig:
	var config = create_config()
	config.deserialize(data)
	return config

func create_state(creator:Cell, config:GeneConfig) -> GeneState:
	return GeneState.new()
	
func create_config() -> GeneConfig:
	return GeneConfig.new()
	
