@tool
extends ProgrammaticTheme

# https://github.com/Inspiaaa/ThemeGen

func setup():
	set_save_path("res://ui/theme/generated/default_theme.tres")

var default_spacing = 4

var default_background_color = Color(0.176, 0.176, 0.176)

var title_background_color = Color.BLACK
var title_border_color = Color(0.223, 0.223, 0.223)

func define_theme():	
	
	define_default_font_size(16)
	
	define_style('PanelContainer', {
		panel = stylebox_flat({
			bg_color = default_background_color,
			content_margin_ = content_margins(default_spacing)
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
		font_color = Color(255, 204, 255),
		font_outline_color = Color(114, 0, 114),
		outline_size = 3,
		font_size = 32
	})
	
	define_style('HBoxContainer', {
		separation = default_spacing
	})

	define_style('VBoxContainer', {
		separation = default_spacing
	})
