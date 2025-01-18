class_name CellDetailsPanel extends PanelContainer

@onready var cell_title: Label = %CellTitle

@onready var start_energy: Label = %StartEnergy
@onready var new_energy: Label = %NewEnergy
@onready var energy_wanted: Label = %EnergyWanted
@onready var max_energy: Label = %MaxEnergy
@onready var energy_used: Label = %EnergyUsed

@onready var start_life: Label = %StartLife
@onready var new_life: Label = %NewLife
@onready var life_lost: Label = %LifeLost
@onready var max_life: Label = %MaxLife

@onready var gene_container: VBoxContainer = %GeneContainer

var displayed_cell_type:CellType = null

func _ready() -> void:
	hide_panel()
	
func show_cell_state(cell_state:CellState) -> void:
	
	var cell_type:CellType = cell_state.cell_type
	if not cell_type:
		hide_panel()
		return
		
	cell_title.text = "%s:%s:%d" % [cell_type.genome.name, cell_type.name, cell_state.cell_number]
	
	start_energy.text = str(cell_state.start_energy)
	max_energy.text = str(cell_state.max_energy)
	new_energy.text = str(cell_state.energy)
	energy_wanted.text = "(%d)" % cell_state.energy_wanted
	energy_used.text = str(cell_state.end_energy - cell_state.start_energy)
	
	start_life.text = str(cell_state.start_life)
	new_life.text = str(cell_state.new_life)
	max_life.text = str(cell_state.max_life)
	life_lost.text = str(cell_state.end_life - cell_state.start_life)

	if displayed_cell_type != cell_type:
		
		for child in gene_container.get_children():
			gene_container.remove_child(child)
		
		for gene_config:GeneConfig in cell_type.gene_configs:
			var gene_type:GeneType = gene_config.gene_type
			gene_container.add_child(gene_type.get_detail_ui())

	#for i in range(cell.genes.size()):
		#var gene = cell.genes[i]
		#var detail_ui = gene_container.get_child(i)
		#detail_ui.show_gene(gene)
	#
	#if cell != _cell:
		#if _cell: _cell.state_changed.disconnect(_on_cell_state_changed)
		#cell.state_changed.connect(_on_cell_state_changed)
		#_cell = cell

	visible = true

func _show_history_prop(history:Dictionary, prop_name:String, history_label:Label) -> void:
	var value = history.get(prop_name)
	if value == null:
		history_label.text = '(none)'
	else:
		history_label.text = "(%d)" % [value]
	
func hide_panel() -> void:
	visible = false
