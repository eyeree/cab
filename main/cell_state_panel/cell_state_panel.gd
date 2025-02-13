class_name CellStatePanel extends PanelContainer

@onready var cell_title: Label = %CellTitle

@onready var cell_state_panel: EqualHBoxContainer = %CellStatePanel

@onready var energy_panel: PanelContainer = %EnergyPanel
@onready var start_energy: Label = %StartEnergy
@onready var new_energy: Label = %NewEnergy
@onready var energy_wanted: Label = %EnergyWanted
@onready var max_energy: Label = %MaxEnergy
@onready var energy_used: Label = %EnergyUsed

@onready var life_panel: PanelContainer = %LifePanel
@onready var start_life: Label = %StartLife
@onready var new_life: Label = %NewLife
@onready var life_lost: Label = %LifeLost
@onready var max_life: Label = %MaxLife

@onready var gene_container: VBoxContainer = %GeneContainer

var displayed_cell_type:CellType = null

func _ready() -> void:
	hide_panel()
	
func show_cell_state(cell_state:CellState) -> void:
	
	var cell:Cell = cell_state.cell
	if not cell:
		hide_panel()
		displayed_cell_type = null
		return
	
	var cell_type:CellType = cell.cell_type
		
	if cell_type.genome.hidden:
		
		cell_title.text = cell_type.name		
		cell_state_panel.visible = false
		
	else:
		
		cell_title.text = cell.title
		
		start_energy.text = str(cell_state.start_energy)
		max_energy.text = str(cell_state.max_energy)
		new_energy.text = "+%d" % cell_state.new_energy
		energy_wanted.text = "(%d)" % cell_state.energy_wanted
		energy_used.text = str(cell_state.end_energy - cell_state.start_energy)
		
		start_life.text = str(cell_state.start_life)
		new_life.text = "+%d" % cell_state.new_life
		max_life.text = str(cell_state.max_life)
		life_lost.text = str(cell_state.end_life - cell_state.start_life)

		cell_state_panel.visible = true

	if displayed_cell_type != cell_type:
		
		for child in gene_container.get_children():
			gene_container.remove_child(child)
		
		for gene_config:GeneConfig in cell_type.gene_configs:
			var gene_type:GeneType = gene_config.gene_type
			var gene_ui:GeneStatePanel = gene_type.get_gene_state_panel()
			if gene_ui != null:
				gene_container.add_child(gene_ui)
			
		displayed_cell_type = cell_type
		
	for gene_ui:GeneStatePanel in gene_container.get_children():
		gene_ui.show_gene_state(cell_state)

	visible = true

func _show_history_prop(history:Dictionary, prop_name:String, history_label:Label) -> void:
	var value = history.get(prop_name)
	if value == null:
		history_label.text = '(none)'
	else:
		history_label.text = "(%d)" % [value]
	
func hide_panel() -> void:
	visible = false
