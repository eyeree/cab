class_name CellDetailsPanel extends PanelContainer

@onready var cell_title: Label = %CellTitle
@onready var energy_edit: LineEdit = %EnergyEdit
@onready var new_energy_edit: LineEdit = %NewEnergyEdit
@onready var energy_wanted_edit: LineEdit = %EnergyWantedEdit
@onready var life_edit: LineEdit = %LifeEdit
@onready var new_life_edit: LineEdit = %NewLifeEdit
@onready var max_life_edit: LineEdit = %MaxLifeEdit
@onready var energy_history_label: Label = %EnergyHistoryLabel
@onready var new_energy_history_label: Label = %NewEnergyHistoryLabel
@onready var energy_wanted_history_label: Label = %EnergyWantedHistoryLabel
@onready var life_history_label: Label = %LifeHistoryLabel
@onready var new_life_history_label: Label = %NewLifeHistoryLabel
@onready var max_life_history_label: Label = %MaxLifeHistoryLabel
@onready var gene_container: VBoxContainer = %GeneContainer

var _cell:Cell = null

func _ready() -> void:
	#hide_panel()
	pass
	
func show_cell_state(state:Dictionary) -> void:
	
	var cell_type:CellType = state.get('cell_type')
	if not cell_type:
		hide_panel()
		return
		
	cell_title.text = "%s:%s:%d" % [cell_type.genome.name, cell_type.name, state['cell_number']]
	energy_edit.text = str(state['energy'])
	new_energy_edit.text = str(state['new_energy'])
	energy_wanted_edit.text = str(state['energy_wanted'])
	life_edit.text = str(state['life'])
	new_life_edit.text = str(state['new_life'])
	max_life_edit.text = str(state['max_life'])
	
	#var history:Dictionary = cell.last_history
	#_show_history_prop(history, 'energy', energy_history_label)
	#_show_history_prop(history, 'new_energy', new_energy_history_label)
	#_show_history_prop(history, 'energy_wanted', energy_wanted_history_label)
	#_show_history_prop(history, 'life', life_history_label)
	#_show_history_prop(history, 'new_life', new_life_history_label)
#
	#if _cell != cell:
		#for child in gene_container.get_children():
			#gene_container.remove_child(child)
		#for gene in cell.genes:
			#gene_container.add_child(gene.get_detail_ui())
			#
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
