class_name SerializationUtil

const OBJ_ID = '_obj_id'
const CLS_ID = '_cls_id'

const ROOT_REF = 'root'
const OBJ_DATA = 'data'

static var _cls_id_to_cls_map:Dictionary[StringName, Script] = {}
static var _cls_to_cls_id_map:Dictionary[Script, StringName] = {}

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
	var new_id:StringName = _cls_to_cls_id_map.get(new_cls)
	if new_id == null:
		push_error('remap of old id "%s" to unregistered class "%s".' % [ old_id, new_cls ])
	_cls_id_to_cls_map.set(old_id, new_cls)

#region Ignored Properties

static var _cls_to_ignored_properties_map:Dictionary[Script, Array] = {}

static var _empty_ignored_property_list:Array[StringName] = []

static func set_ignored_properties(cls:Script, property_names:Array[StringName]) -> void:
	var base_cls:Script = cls.get_base_script()
	while base_cls != null:
		if _cls_to_ignored_properties_map.has(base_cls):
			property_names.append_array(_cls_to_ignored_properties_map.get(base_cls))
		base_cls = base_cls.get_base_script()
	_cls_to_ignored_properties_map.set(cls, property_names)

#endregion	

#region Helpers

static var _cls_id_to_helper_map:Dictionary[StringName, SerializationHelper] = {}

static func set_helper(cls:Script, helper:SerializationHelper) -> void:
	var id = _cls_to_cls_id_map.get(cls)
	if id == null:
		push_error('cannot set helper for unregistered class %s' % [cls])
	_cls_id_to_helper_map.set(id, helper)

class SerializationHelper extends RefCounted:
	func serialize(_ctx:SerializationContext, _object:Object) -> Dictionary:
		push_error('SerializationHelper.serialize was not overridden')
		return {}
	func deserialize(_ctx:DeserializationContext, _data:Dictionary, _ref:Dictionary) -> Object:
		push_error('SerializationHelper.deserialize was not overridden')
		return null

class ResourceReferenceSerializationHelper extends SerializationHelper:
	
	const RESOURCE_PATH = '_resource_path'
	
	static var singelton:ResourceReferenceSerializationHelper = ResourceReferenceSerializationHelper.new()
	
	func serialize(_ctx:SerializationContext, object:Object) -> Dictionary:
		if object is Resource:
			return { RESOURCE_PATH: object.resource_path }
		else:
			push_error('cannot serialize object %s as resource reference' % object)
			return { RESOURCE_PATH: null }
			
	func deserialize(_ctx:DeserializationContext, data:Dictionary, _ref:Dictionary) -> Object:
		var resource_path = data[RESOURCE_PATH]
		return load(resource_path)

class SceneFilePathSerializationHelper extends SerializationHelper:
	
	const SCENE_FILE_PATH = '_scene_file_path'
	
	static var singelton:SceneFilePathSerializationHelper = SceneFilePathSerializationHelper.new()
	
	func serialize(_ctx:SerializationContext, object:Object) -> Dictionary:
		if object is Node and object.scene_file_path != '':
			return { SCENE_FILE_PATH: object.scene_file_path }
		else:
			push_error('cannot serialize object %s as scene file path' % object)
			return { SCENE_FILE_PATH: null }
			
	func deserialize(_ctx:DeserializationContext, data:Dictionary, _ref:Dictionary) -> Object:
		var resource_path = data[SCENE_FILE_PATH]
		var packed_scene:PackedScene = load(resource_path)
		return packed_scene.instantiate()
			
#endregion

#region Registration
	
class SerializationBuilder:
	
	func remap(old_id:StringName, new_cls:Script) -> SerializationBuilder:
		SerializationUtil.remap(old_id, new_cls)
		return self
		
	func helper(cls:Script, helper_:SerializationHelper) -> SerializationBuilder:
		SerializationUtil.set_helper(cls, helper_)
		return self
		
	func use_resource_path_for(cls:Script) -> SerializationBuilder:
		return helper(cls, ResourceReferenceSerializationHelper.singelton)
		
	func use_scene_file_path_for(cls:Script) -> SerializationBuilder:
		return helper(cls, SceneFilePathSerializationHelper.singelton)
		
	func ignore_properties(cls:Script, property_names:Array[StringName]) -> SerializationBuilder:
		SerializationUtil.set_ignored_properties(cls, property_names)
		return self

static var builder:SerializationBuilder = SerializationBuilder.new()

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
	_cls_id_to_cls_map.set(id, cls)
	_cls_to_cls_id_map.set(cls, id)

#endregion

#region Serialization

class SerializationContext:
	var obj_to_ref_map:Dictionary[Object, Dictionary] = {}
	var ref_to_data_map:Dictionary[Dictionary, Variant] = {}
	
	func get_ref(obj:Object) -> Variant:
		return obj_to_ref_map.get(obj)
		
	func create_ref(obj:Object) -> Dictionary:
		var obj_id = obj_to_ref_map.size()
		var ref = { OBJ_ID: obj_id }
		obj_to_ref_map.set(obj, ref)
		return ref
		
	func set_ref_data(ref:Dictionary, data:Variant) -> void:
		ref_to_data_map.set(ref, data)
		
	func get_data() -> Array[Variant]:
		var keys:Array = ref_to_data_map.keys()
		keys.sort_custom(func(a, b): return a[OBJ_ID] < b[OBJ_ID])
		var result:Array = []
		result.resize(keys.size())
		for index:int in range(keys.size()):
			result[index] = ref_to_data_map[keys[index]]
		return result
		
static func serialize(root:Object) -> Dictionary:
	var ctx = SerializationContext.new()
	var ref = serialize_object(ctx, root)
	return {
		ROOT_REF: ref,
		OBJ_DATA: ctx.get_data()
	}
		
static func serialize_object(ctx:SerializationContext, object:Object) -> Dictionary:
	var ref = ctx.get_ref(object)
	if ref:
		return ref
	else:
		var data:Dictionary = {}
		ref = ctx.create_ref(object)
		var cls_id = _cls_to_cls_id_map.get(object.get_script())
		if cls_id == null:
			push_error('unregisted object type %s' % [object.get_script()])
		else:
			var helper = _cls_id_to_helper_map.get(cls_id)
			if helper:
				data = helper.serialize(object)
			elif object.has_method('serialize'):
				data = object.call('serialize')
			else:
				data = serialize_properties(ctx, object)
			data.set(CLS_ID, cls_id)
		ctx.set_ref_data(ref, data)
		return ref
	
static func serialize_array(ctx:SerializationContext, array:Array) -> Array:
	return array.map(func (entry): return serialize_value(ctx, entry))
	
static func serialize_dictionary(ctx:SerializationContext, dictionary:Dictionary) -> Dictionary:
	var result = {}
	for key in dictionary.keys():
		result[serialize_value(ctx, key)] = serialize_value(ctx, dictionary[key])
	return result

static func serialize_properties(ctx:SerializationContext, object:Object) -> Dictionary:
	
	var cls = object.get_script()
	
	var ignored_properties:Array[StringName] = _cls_to_ignored_properties_map.get(cls) \
		if _cls_to_ignored_properties_map.has(cls) else _empty_ignored_property_list
		
	var result:Dictionary = {}
	for prop:Dictionary in object.get_property_list():
		
		if prop['usage'] & PropertyUtil.PropertyUsageFlags.SCRIPT_VARIABLE == 0:
			continue
	
		var name = prop['name']
		if ignored_properties.find(name) != -1:
			continue
			
		var value = object.get(name)
		result.set(name, serialize_value(ctx, value))
				
	return result
	
static func serialize_value(ctx:SerializationContext, value:Variant) -> Variant:
	match typeof(value):
		
		Variant.Type.TYPE_NIL:
			return null
			
		Variant.Type.TYPE_OBJECT:
			return serialize_object(ctx, value)
				
		Variant.Type.TYPE_ARRAY:
			return serialize_array(ctx, value)
				
		Variant.Type.TYPE_DICTIONARY:
			return serialize_dictionary(ctx, value)
				
		Variant.Type.TYPE_CALLABLE, \
		Variant.Type.TYPE_SIGNAL:
			return null
			
		_:
			return var_to_str(value)

#endregion

#region Deserialization

static func _is_obj_ref(data:Dictionary) -> bool:
	return data.has(OBJ_ID)
	
class DeserializationContext:
	var _obj_data:Array
	var _obj_id_to_obj_map:Dictionary[int, Object] = {}
	
	func _init(obj_data:Array):
		_obj_data = obj_data
		
	func get_obj(ref:Dictionary) -> Object:
		var obj_id = ref[OBJ_ID]
		if _obj_id_to_obj_map.has(obj_id):
			return _obj_id_to_obj_map[obj_id]
		else:
			var data = _obj_data[obj_id]
			var obj = SerializationUtil.deserialize_object(self, data, ref)
			_obj_id_to_obj_map.set(obj_id, obj)
			return obj
			
	func add_obj(ref:Dictionary, object:Object) -> void:
		var obj_id = ref[OBJ_ID]
		_obj_id_to_obj_map.set(obj_id, object)
		
static func deserialize(data:Dictionary) -> Object:
	var ctx = DeserializationContext.new(data[OBJ_DATA])
	var root_ref = data[ROOT_REF]
	var root = ctx.get_obj(root_ref)
	return root
	
static func deserialize_properties(ctx:DeserializationContext, data:Dictionary, object:Object) -> void:
	for prop:Dictionary in object.get_property_list():
		var name = prop['name']
		if data.has(name):
			match prop['type']:
				Variant.Type.TYPE_ARRAY:
					var value = deserialize_value(ctx, data[name])
					var existing = object.get(name)
					if existing is Array:
						existing.append_array(value)
					else:
						object[name] = value
				_:	
					object[name] = deserialize_value(ctx, data[name])
				
static func deserialize_value(ctx:DeserializationContext, value:Variant) -> Variant:
	match typeof(value):
		
		Variant.Type.TYPE_NIL:
			return null
		
		Variant.Type.TYPE_DICTIONARY:
			if _is_obj_ref(value):
				return ctx.get_obj(value)
			else:
				return deserialize_dictionary(ctx, value)
				
		Variant.Type.TYPE_ARRAY:
			return deserialize_array(ctx, value)
			
		Variant.Type.TYPE_STRING, Variant.Type.TYPE_STRING_NAME:
			return str_to_var(value)
			
		_:
			return null

static func deserialize_object(ctx:DeserializationContext, data:Dictionary, ref:Dictionary) -> Object:
	var result:Object = null
	var id:StringName = data[CLS_ID]
	var helper = _cls_id_to_helper_map.get(id)
	if helper:
		result = helper.deserialize(ctx, data, ref)
	else:
		var cls:Script = _cls_id_to_cls_map.get(id)
		if cls == null:
			push_error('No script for id "%s" is registered' % [id])
		elif cls.has_method('deserialize'):
			result = cls.call('deserialize', ctx, data, ref)
		else:
			result = cls.new()
			ctx.add_obj(ref, result)
			deserialize_properties(ctx, data, result)
	if result.has_method('_on_deserialized'):
		result.call('_on_deserialized')
	return result

static func deserialize_dictionary(ctx:DeserializationContext, dictionary:Dictionary) -> Dictionary:
	var result = {}
	for key in dictionary.keys():
		result[deserialize_value(ctx, key)] = deserialize_value(ctx, dictionary[key])
	return result
	
static func deserialize_array(ctx:DeserializationContext, array:Array) -> Array:
	return array.map(
		func (entry):
			return deserialize_value(ctx, entry)
	)
	
#endregion
