class_name SerializationUtil

static var _uid_to_script_map:Dictionary[StringName, Script] = {}
static var _script_to_uid_map:Dictionary[Script, StringName] = {}
static var _ignored_property_map:Dictionary[Script, Array] = {}
static var _id_to_helper_map:Dictionary[StringName, SerializationHelper] = {}

class SerializationHelper extends RefCounted:
	func serialize(object:Object) -> Dictionary:
		return {}
	func deserialize(data:Dictionary) -> Object:
		return null
		
class ResourceReferenceSerializationHelper extends SerializationHelper:
	
	static var singelton:ResourceReferenceSerializationHelper = ResourceReferenceSerializationHelper.new()
	
	func serialize(object:Object) -> Dictionary:
		if object is Resource:
			return { 'resource_path': object.resource_path }
		else:
			push_error('cannot serialize object %s as resource reference' % object)
			return { 'resource_path': null }
			
	func deserialize(data:Dictionary) -> Object:
		var resource_path = data['resource_path']
		return load(resource_path)
	

static func _get_root_class_id(root_cls:Script) -> String:
	
	var root_path:String = root_cls.resource_path
	if root_path == '':
		push_error('root class %s has no resource path (it is not a root class).' % [root_cls])
		return ''
		
	var root_id:int = ResourceLoader.get_resource_uid(root_cls.resource_path)
	if root_id == -1:
		push_error('root class %s with path "%s" has no uid (unexpected).' % [root_path, root_cls])
		return ''
	
	return StringName(str(root_id))
	
static func remap(old_id:StringName, new_cls:Script) -> void:
	var new_id:StringName = _script_to_uid_map.get(new_cls)
	if new_id == null:
		push_error('remap of old id "%s" to unregistered class "%s".' % [ old_id, new_cls ])
	_uid_to_script_map.set(old_id, new_cls)
	
static func _get_ignored_properties(cls:Script) -> Array[StringName]:
	var ignored_properties:Array[StringName] = []
	if cls.has_method('_identify_ignored_properties'):
		cls.call('_identify_ignored_properties', ignored_properties)
	return ignored_properties
	
class SerializationBuilder:
	
	func remap(old_id:StringName, new_cls:Script) -> SerializationBuilder:
		SerializationUtil.remap(old_id, new_cls)
		return self
		
	func helper(cls:Script, helper:SerializationHelper) -> SerializationBuilder:
		SerializationUtil.set_helper(cls, helper)
		return self
		
	func as_resource_path(cls:Script) -> SerializationBuilder:
		return helper(cls, ResourceReferenceSerializationHelper.singelton)

static var builder:SerializationBuilder = SerializationBuilder.new()

static func nested(root_cls:Script)

static func register_resource(root_cls:Script) -> SerializationBuilder:
	var root_id:StringName = _get_root_class_id(root_cls)
	if root_id != '':
		_set_helper(root_id, ResourceReferenceSerializationHelper.singelton)
	return SerializationBuilder(root_id, root_cls)

static func register(root_cls:Variant, nested_map:Dictionary[String, Variant] = {}) -> SerializationBuilder:
	var root_id:StringName = _get_root_class_id(root_cls)
	if root_id != '':
		_register(root_id, root_cls)
		_register_nested(root_id, nested_map)
	return builder

static func register_nested(root_cls:Variant, nested_map:Dictionary[String, Variant]) -> SerializationBuilder:
	var root_id:StringName = _get_root_class_id(root_cls)
	if root_id != '': _register_nested(root_id, nested_map)
	return builder
	
static func _register_nested(root_id:StringName, nested_map:Dictionary[String, Variant]) -> void:
	for nested_name in nested_map.keys():
		var nested_cls = nested_map.get(nested_name)
		var nested_id = "%s#%s" % [root_id, nested_name]
		_register(nested_id, nested_cls)
		
static func _register(id:StringName, cls:Script) -> void:
	_uid_to_script_map.set(id, cls)
	_script_to_uid_map.set(cls, id)
	_ignored_property_map.set(cls, _get_ignored_properties(cls))

static func set_helper(cls:Script, helper:SerializationHelper) -> void:
	var id = _script_to_uid_map.get(cls)
	if id == null:
		push_error('cannot set helper for unregistered class %s' % [cls])
	_id_to_helper_map.set(id, helper)
	
static func serialize_object(object:Object) -> Dictionary:
	var id = _script_to_uid_map.get(object.get_script())
	if id == '':
		push_error('unregisted object type %s' % [object.get_script()])
		return {}
	var result
	var helper = _id_to_helper_map.get(id)
	if helper:
		result = helper.serialize(object)
	elif object.has_method('serialize'):
		result = object.call('serialize')
	else:
		result = serialize_properties(object)
	result.set('_class_id', id)
	return result
	
static func serialize_array(array:Array) -> Array:
	return array.map(serialize_value)
	
static func serialize_dictionary(dictionary:Dictionary) -> Dictionary:
	var result = {}
	for key in dictionary.keys():
		result[key] = serialize_value(dictionary[key])
	return result

static func serialize_properties(object:Object) -> Dictionary:
	
	var cls = object.get_script()
	if not _ignored_property_map.has(cls):
		_ignored_property_map.set(cls, _get_ignored_properties(cls))
	var ignored_properties:Array[StringName] = _ignored_property_map.get(cls)
		
	var result:Dictionary = {}
	for prop:Dictionary in object.get_property_list():
		
		if prop['usage'] & PropertyUtil.PropertyUsageFlags.SCRIPT_VARIABLE == 0:
			continue
	
		var name = prop['name']
		if ignored_properties.find(name) != -1:
			continue
			
		var value = object.get(name)
		result.set(name, serialize_value(value))
				
	return result
	
static func serialize_value(value:Variant) -> Variant:
	match typeof(value):
		
		Variant.Type.TYPE_NIL:
			return null
			
		Variant.Type.TYPE_OBJECT:
			return serialize_object(value)
				
		Variant.Type.TYPE_ARRAY:
			return serialize_array(value)
				
		Variant.Type.TYPE_DICTIONARY:
			return serialize_dictionary(value)
				
		Variant.Type.TYPE_CALLABLE, \
		Variant.Type.TYPE_SIGNAL:
			return null
			
		_:
			return var_to_str(value)

	
static func deserialize_properties(data:Dictionary, object:Object) -> void:
	for prop:Dictionary in object.get_property_list():
		var name = prop['name']
		if data.has(name):
			object[name] = deserialize_value(data[name])

				
static func deserialize_value(value:Variant) -> Variant:
	match typeof(value):
		
		Variant.Type.TYPE_NIL:
			return null
		
		Variant.Type.TYPE_DICTIONARY:
			if value.has("_class_id"):
				return deserialize_object(value)
			else:
				return deserialize_dictionary(value)
				
		Variant.Type.TYPE_ARRAY:
			return deserialize_array(value)
			
		Variant.Type.TYPE_STRING, Variant.Type.TYPE_STRING_NAME:
			return str_to_var(value)
			
		_:
			return null

static func deserialize_object(data:Dictionary) -> Object:
	var id:StringName = data['_class_id']
	var helper = _id_to_helper_map.get(id)
	if helper:
		return helper.deserialize(data)
	else:
		var cls:Script = _uid_to_script_map.get(id)
		if cls == null:
			push_error('No script for id "%s" is registered' % [id])
			return null
		elif cls.has_method('deserialize'):
			return cls.call('deserialize', data)
		else:
			var result = cls.new()
			deserialize_properties(data, result)
			return result

static func deserialize_dictionary(dictionary:Dictionary) -> Dictionary:
	var result = {}
	for key in dictionary.keys():
		result[key] = deserialize_value(dictionary[key])
	return result
	
static func deserialize_array(array:Array) -> Array:
	return array.map(
		func (entry):
			return deserialize_value(entry)
	)
