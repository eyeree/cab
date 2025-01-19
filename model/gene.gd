class_name Gene extends RefCounted

var _cell_ref:WeakRef
var cell:Cell:
	get: return _cell_ref.get_ref()

func _init(cell_:Cell) -> void:
	_cell_ref = weakref(cell_)
		
# All gene derived classes must define:
#
#     static var gene_type_:SomeGeneType = SomeGeneType.new()
#
# GDScript resolves instance property access with static property values. So
# gene.gene_type should work, but isn't defined by Gene. You can use gene_type_
# as an alternative.

var gene_type:GeneType:
	get: 
		return self.get('gene_type_')

var energy_wanted:int = 0

func perform_actions() -> void:
	pass
				
func update_state() -> void:
	pass

func apply_damage_resistance(_source_index:HexIndex, _damage_amount:int, _damage_type:Cell.DamageType) -> int:
	return 0
	
func init_cell(_cell:Cell) -> void:
	pass
	
func add_state(gene_state:GeneState) -> void:
	cell.state.substates.append(gene_state)
	
#static var debug_genes:Array[String] = []
#
#func debug_gene(msg:String, args:Array) -> void:
	#if debug_genes.has(gene_type.name):
		#prints("Cell %s - Gene %s - %s" % [cell, gene_type.name, msg % args])
