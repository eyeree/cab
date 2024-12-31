class_name Test extends Node3D

static func _static_init():
	prints('_static_init')
	SerializationUtil.register_nested(Test, {
		Foo = Foo, 
		Bar = Bar,
		Root = Root
	}) \
	.ignore_properties(Base, ['y']) \
	.ignore_properties(Foo, ['z']) \
	.ignore_properties(Bar, ['z'])

class Base:
	var x:String = 'x'
	var y:String = 'y'
	
class Foo extends Base:
	var root:Root
	var a:String
	var z:String = 'z'
	var bar:Bar

class Bar extends Base:
	var b:String
	var z:String = 'z'
	
class Root:
	var foos:Array[Foo] = []
	
func _init():
	prints('_init')
	
func _ready():
	
	prints('self', self, self.get_script(), self.get_script().resource_path)
	
	#prints(Bar._self, Bar._self.resource_path)
	#
	#if Bar._factory is Callable:
		#prints(Bar._factory.get_object(), Bar._factory.get_method())
	
	#var s = self.get_script()
	#var F:GDScript = s.get('Foo')
	#var B:GDScript = s.get('Base')
	#prints('F', F, ':', B, ':', F.get_base_script(), ':', F.get_global_name(), ':', F.get_instance_base_type(), ':', F.resource_name, ':', F.resource_path, ':', F.get_class(), ':', F.get_script())
	
	var foo1 = Foo.new()
	foo1.a = 'foo1'
	foo1.bar = Bar.new()
	foo1.bar.b = 'bar1'

	var foo2 = Foo.new()
	foo1.a = 'foo1'
	foo2.bar = foo1.bar
	
	var root = Root.new()
	root.foos.append(foo1)
	root.foos.append(foo2)
	foo1.root = root
	foo2.root = root

	var s = SerializationUtil.serialize(root)
	prints("s", s)
	var r = SerializationUtil.deserialize(s)
	prints(r, r is Root, r.foos[0] != r.foos[1], r.foos[0].bar == r.foos[1].bar)
	prints(r.foos[0].bar, r.foos[1].bar)
	prints(r.foos[0].root == r, r.foos[1].root == r)
	
	#prints(foo, foo is Foo, foo.bar, foo.bar is Bar)
	#
	#var s0 = SerializationUtil.serialize_object(foo)
	#var f0 = SerializationUtil.deserialize_object(s0)
	#prints(f0, f0.a, f0 is Foo, f0.bar, f0.bar.b, f0.bar is Bar)
	#prints(s0)
	#prints(JSON.stringify(s0))
	
	#var s1 = var_to_str(foo)
	#var f1 = str_to_var(s1)
	#prints(f1, f1 is Foo, f1.bar, f1.bar is Bar)
	
	#var s2 = var_to_bytes(foo)
	#var f2 = bytes_to_var(s2)
	#prints(f2, f2 is Foo, f2.bar, f2.bar is Bar)

	#var s3 = var_to_bytes_with_objects(foo)
	#var f3 = bytes_to_var_with_objects(s3)
	#prints(f3, f3 is Foo, f3.bar, f3.bar is Bar)
		
	#prints('foo.a', foo.a)
	#
	#var ser = SerializationUtil.serialize_properties(foo)
	#prints('ser', ser)
	#
	#var f2 = Foo.new()
	#SerializationUtil.deserialize_properties(ser, f2)
	#prints(f2, f2.a, f2.bar, f2.bar is Bar)
	#prints(f2.a, f2.bar.b, f2 is Foo, f2.b is Bar)
	
	#var s1 = var_to_str(Vector3(1, 2, 3))
	#var s2 = var_to_str([Vector3.INF, Vector3(3, 2, 1)])
	#prints(s1, s2)
	#var v1 = str_to_var(s1)
	#prints(v1)
	#var v2 = str_to_var(s2)
	#prints(v2)

	#var a:Array[Array] = []
	#
	#a.resize(3)
	#prints(a[0], a[1], a[2])
	
	#var i1 = Gene.get_instance(GrowTenderalGene)
	#var s = i1.serialize()
	#var i2 = Gene.deserialize(s)
	#prints(i1, s, i2)
	
	#var res:PackedScene = load(path)
	#prints(res)
	#
	#var ap:AppearanceSet = res.instantiate()
	#
	#for ca:CellAppearance in ap.get_cell_appearances():
		#prints('ca', ca)
		#for ea:EffectAppearance in ca.supported_effects:
			#prints('  ea', ea)
			#
	#for ea:EffectAppearance in ap.get_effect_appearances():
		#prints('ea', ea)
	#
	#var s = ap.serialize()
	#prints(s, ap)
	#
	#var ap2 = AppearanceSet.deserialize(s)
	#prints(ap2)	
	
	
	#var instance:Gene = cls.new()
	#prints(cls.gene_name, instance.gene_name)
	#
	#var script:Script = load(script_path)
	#prints(script.gene_name)
	#prints(script.get_script_constant_map())
	#
	#var i2:Gene = script.new()
	#prints(i2)
