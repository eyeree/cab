class_name EditPanel extends PanelContainer

@onready var _genomes_container: VBoxContainer = %GenomesContainer
@onready var _add_genome_buttom: Button = %AddGenomeButtom

const GENOME_PANEL := preload("res://main/edit_panel/genome_panel.tscn")

signal cell_type_selected(cell_type:CellType)

var _selected_cell_type_genome_panel:GenomePanel = null

func _ready() -> void:
	_add_genome_buttom.pressed.connect(_add_genome)
	
func _add_genome() -> void:
	pass

func show_genomes(genomes:Array[Genome]):
	for genome_panel in _genomes_container.get_children().slice(0, -1):
		genome_panel.cell_type_selected.disconnect(_cell_type_selected)
		genome_panel.remove_genome.disconnect(_remove_genome)
		_genomes_container.remove_child(genome_panel)
		genome_panel.queue_free()
	for genome in genomes:
		var genome_panel = GENOME_PANEL.instantiate()
		_genomes_container.add_child(genome_panel)
		_genomes_container.move_child(genome_panel, -2)
		genome_panel.cell_type_selected.connect(_cell_type_selected)
		genome_panel.remove_genome.connect(_remove_genome)
		genome_panel.show_genome(genome)
		
func _cell_type_selected(cell_type:CellType) -> void:
	if _selected_cell_type_genome_panel != null and (cell_type == null or _selected_cell_type_genome_panel.genome != cell_type.genome):
		_selected_cell_type_genome_panel.clear_cell_type_selection()
		_selected_cell_type_genome_panel = null
	if cell_type != null and _selected_cell_type_genome_panel == null:
		var i = _genomes_container.get_children().find_custom(
			func (child): 
				return child is GenomePanel and child.genome == cell_type.genome)
		_selected_cell_type_genome_panel = _genomes_container.get_child(i)
	cell_type_selected.emit(cell_type)
	
func _remove_genome(genome:Genome) -> void:
	pass
