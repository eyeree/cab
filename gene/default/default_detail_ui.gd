class_name DefaultGeneDetailUI extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var property_grid_container: GridContainer = %PropertyGridContainer
@onready var template_label: Label = %TemplateLabel
@onready var template_line_edit: LineEdit = %TemplateLineEdit

func show_gene(gene:Gene) -> void:
	title_label.text = gene.gene_type.name
	
	for child:Node in get_children().slice(2): # TODO num templates
		child.queue_free()
	
	for prop in gene.get_property_list():
		if prop['usage'] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			
			var value_control:Control = null
			match prop['type']:
				TYPE_INT:
					value_control = template_line_edit.duplicate()
					value_control.text = str(gene.get(prop['name']))
					value_control.alignment = HORIZONTAL_ALIGNMENT_RIGHT
				TYPE_FLOAT:
					value_control = template_line_edit.duplicate()
					value_control.text = "%0.4f" % [gene.get(prop['name'])]
					value_control.alignment = HORIZONTAL_ALIGNMENT_RIGHT
				TYPE_STRING, TYPE_STRING_NAME:
					value_control = template_line_edit.duplicate()
					value_control.text = str(gene.get(prop['name']))
					
			if value_control != null:

				var label:Label = template_label.duplicate()
				label.text = prop['name'].capitalize() + ":"
				label.visible = true
				property_grid_container.add_child(label)

				value_control.visible = true
				property_grid_container.add_child(value_control)
