@tool
extends ProgrammaticTheme

# https://github.com/Inspiaaa/ThemeGen

func setup():
	set_save_path("res://ui/theme/generated/default_theme.tres")

var default_spacing = 4

var default_background_color = Color(0.176, 0.176, 0.176)
var default_border_color = Color(0.223, 0.223, 0.223)
var default_font_color = Color(1, 1, 1)
var form_value_font_color = default_font_color
var form_label_font_color = Color(0.545, 0.545, 0.545)

var title_background_color = Color.BLACK
var title_border_color = default_border_color
var title_font_color = Color(255, 204, 255)
var title_font_outline_color = Color(114, 0, 114)

func define_theme():	
	
	define_default_font_size(16)
	
	var panel_style = stylebox_flat({
		bg_color = default_background_color,
		content_margin_ = content_margins(default_spacing)
	})
	
	define_style('PanelContainer', {
		panel = panel_style
	})
	
	define_variant_style("DetailPanel", "PanelContainer", {
		panel = inherit(panel_style, {
			border_color = default_border_color,
			border_ = border_width(2)
		})
	})	
	
	define_variant_style("TitlePanel", "PanelContainer", {
		panel = stylebox_flat({
			bg_color = title_background_color,
			border_color = title_border_color,
			border_ = border_width(2),
			content_margin_left = 10,
			content_margin_right = 10,
			content_margin_top = 0,
			content_margin_bottom = 1
		})
	})
	
	define_variant_style("TitleLabel", "Label", {
		font_color = title_font_color,
		font_outline_color = title_font_outline_color,
		outline_size = 3,
		font_size = 32
	})
	
	define_variant_style("FormLabel", "Label", {
		font_color = form_label_font_color
	})
	
	define_variant_style("FormValueLabel", "Label", {
		font_color = form_value_font_color
	})
	
	define_variant_style("FormValueLineEdit", "LineEdit", {
		font_color = form_value_font_color
	})
	
	define_style('HBoxContainer', {
		separation = default_spacing
	})

	define_style('VBoxContainer', {
		separation = default_spacing
	})

	define_variant_style("FormGridContainer", "GridContainer", {
		h_separation = default_spacing
	})
