extends Node3D

var path:String = "res://appearance/place_holder_a/place_holder_a_appearance_set.tscn"

func _ready():
	
	var a:Array[Array] = []
	
	a.resize(3)
	prints(a[0], a[1], a[2])
	
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
