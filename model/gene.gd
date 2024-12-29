class_name Gene extends RefCounted

static var _instance_map:Dictionary[StringName, Gene] = {}

static func get_instance(script_or_path:Variant) -> Gene:
	var resource_path:StringName = script_or_path.resource_path \
		if script_or_path is Script else script_or_path
	var instance:Gene = _instance_map.get(resource_path)
	if not instance:
		var script:Script = script_or_path \
			if script_or_path is Script else load(resource_path)
		instance = script.new()
		_instance_map.set(resource_path, instance)
	return instance

var name:String = "(new gene)"
var required_effects:Array[StringName] = []

func serialize() -> Variant:
	var script:Script = get_script()
	return script.resource_path
	
static func deserialize(data:Variant) -> Gene:
	return get_instance(data)

func use_energy(index:HexIndex, world:World, cell:Cell) -> void:
	pass
	
func aquire_energy(index:HexIndex, wolrd:World, cell:Cell) -> void:
	pass
