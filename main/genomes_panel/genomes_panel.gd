class_name GenomesPanel extends PanelContainer

@onready var _genomes_container: VBoxContainer = %GenomesContainer
@onready var _add_genome_buttom: Button = %AddGenomeButtom

const GENOME_PANEL := preload("res://main/genomes_panel/genome_panel.tscn")

func _ready() -> void:
	_add_genome_buttom.pressed.connect(_add_genome)
	
func _add_genome() -> void:
	pass

func show_genomes():
	for genome_panel in _genomes_container.get_children().slice(0, -1):
		_genomes_container.remove_child(genome_panel)
		genome_panel.queue_free()
	for genome in Level.current.genomes:
		var genome_panel = GENOME_PANEL.instantiate()
		_genomes_container.add_child(genome_panel)
		_genomes_container.move_child(genome_panel, -2)
		genome_panel.show_genome(genome)
		
