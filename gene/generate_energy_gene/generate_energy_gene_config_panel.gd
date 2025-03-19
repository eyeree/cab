class_name GenerateEnergyGeneConfigPanel extends GeneConfigPanel

@onready var _energy_gained_spin_box: SpinBox = %EnergyGainedSpinBox

var _gene_config:GenerateEnergyGeneConfig

func _ready() -> void:
	_energy_gained_spin_box.value_changed.connect(_on_energy_gained_spin_box_value_changed)

func show_gene_config(gene_config_:GeneConfig) -> void:
	_gene_config = gene_config_
	_energy_gained_spin_box.set_value_no_signal(_gene_config.energy_per_step)

func _on_energy_gained_spin_box_value_changed(value:float) -> void:
	_gene_config.energy_per_step = int(value)
	Level.current.modified()
