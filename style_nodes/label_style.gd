@tool
class_name LabelStyle extends StyleNode


var _font_color_set:bool = false
@export() var font_color:Color = Color.BLACK:
	set(value):
		prints('font_color set', value)
		font_color = value
		_style_modified()

var _foo_set:bool = false		
var foo:String = ""

func _validate_property(property: Dictionary) -> void:
	match property.name:
		'font_color':
			prints('_validate_property', property)
			property.usage |= PROPERTY_USAGE_CHECKABLE
			#if _font_color_set: property.usage |= PROPERTY_USAGE_CHECKED
		'foo':
			prints('_validate_property', property, property.usage & PROPERTY_USAGE_CHECKABLE, property.usage & PROPERTY_USAGE_CHECKED)
			property.usage |= PROPERTY_USAGE_CHECKABLE | PROPERTY_USAGE_EDITOR
			if _foo_set: 
				prints("_foo_set")
				property.usage |= PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_CHECKED 
			
			
func _init() -> void:
	super._init([Label])
	
func _update_target(target:Control) -> void:
	target.add_theme_color_override("font_color", font_color)

func _clear_target(target:Control) -> void:
	target.remove_theme_color_override("font_color")
