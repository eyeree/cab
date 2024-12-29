class_name EnvionmentGenome extends Genome

class EmptyCellType extends CellType:
	func _init():
		name = "Empty"
	
class BoundsCellType extends CellType:
	func _init():
		name = "Bounds"
	
func _init():
	name = "Envionment"
	cell_types = [EmptyCellType.new(), BoundsCellType.new()]
	
static func is_empty_cell(cell:Cell) -> bool:
	return cell.cell_type is EmptyCellType
	
static func is_bounds_cell(cell:Cell) -> bool:
	return cell.cell_type is BoundsCellType

static var _instance:EnvironmentGenom = EnvironmentGenom.new()

static var empty_cell:Cell = new Cell(_instance)
