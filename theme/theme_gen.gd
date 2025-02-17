@tool
extends ProgrammaticTheme

# https://github.com/Inspiaaa/ThemeGen

func setup():
	set_save_path("res://theme/generated/default_theme.tres")

var default_spacing = 4
var default_font_size = 12

var bold_font = load("res://theme/fonts/system/bold_system_font_variation.tres")

var default_background_color = Color(0, 0, 0)
var default_border_color = Color(0.45, 0.07, 0.401)
var default_font_color = Color(0.937, 0.451, 1.0)

var overlay_background_color = Color(0.176, 0.176, 0.176, 0.65)

var form_value_font_color = default_font_color
var form_label_font_color = Color(0.545, 0.545, 0.545)

var detail_border_color = default_border_color
var detail_background_color = Color(0.072, 0.001, 0.079)

var major_sub_detail_border_color = Color(0.841, 0.001, 0.929)
var major_sub_detail_background_color = Color(0.312, 0.013, 0.335)

var sub_detail_border_color = default_border_color.darkened(0.2)

var title_background_color = Color.BLACK
var title_border_color = default_border_color
var title_font_color = Color(0.94, 0.628, 0.96)
var title_font_outline_color = Color(0.841, 0.001, 0.929)

func define_theme():	
	
	define_default_font_size(default_font_size)
	
	var default_panel_style = stylebox_flat({
		bg_color = default_background_color,
		content_margin_ = content_margins(default_spacing)
	})
	
	var base_detail_panel_stype = merge(default_panel_style, {
		bg_color = detail_background_color
	})
	
	var thin_border_panel_style = stylebox_flat({
		border_color = default_border_color,
		border_ = border_width(1)
	})

	var thick_border_panel_style = stylebox_flat({
		border_color = default_border_color,
		border_ = border_width(2)
	})
	
	define_style('PanelContainer', {
		panel = default_panel_style
	})
	
	define_variant_style("DetailPanel", "PanelContainer", {
		panel = merge(base_detail_panel_stype, thick_border_panel_style, {
			content_margin_ = content_margins(default_spacing * 2)
		})
	})
	
	define_variant_style("SubDetailPanel", "PanelContainer", {
		panel = merge(base_detail_panel_stype, thin_border_panel_style, {
		})
	})

	define_variant_style("MajorSubDetailPanel", "PanelContainer", {
		panel = merge(default_panel_style, thin_border_panel_style, {
			bg_color = major_sub_detail_background_color,
			border_color = major_sub_detail_border_color
		})
	})
	
	define_variant_style("NestedDetailPanel", "PanelContainer", {
		panel = stylebox_flat({
			bg_color = detail_background_color,
			content_margin_ = content_margins(0)
		})
	})
		
	define_variant_style("DetailTitleLabel", "Label", {
		font_size = default_font_size + 4
	})

	define_variant_style("SubDetailTitleLabel", "Label", {
		font_size = default_font_size + 2
	})
	
	define_variant_style("Border", "PanelContainer", {
		panel = merge(default_panel_style, thick_border_panel_style)
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

	define_variant_style("OverlayLabel", "Label", {
		font_size = default_font_size * 6
	})
	
	define_variant_style("OverlayPanelInner", "PanelContainer", {
		panel = inherit(default_panel_style, {
			content_margin_ = content_margins(default_spacing * 4)
		})
	})
	
	define_variant_style("OverlayPanelOuter", "Panel", {
		panel = inherit(default_panel_style, {
			content_margin_ = content_margins(0),
			bg_color = overlay_background_color
		})
	})

	define_variant_style("NomarginPanelContainer", "PanelContainer", {
		panel = stylebox_flat({
			bg_color = default_background_color,
			content_margin_ = content_margins(0)
		})
	})
	
	define_variant_style("GridHeaderLabel", "Label", {
		font_size = default_font_size - 2,
		font_color = form_label_font_color,
		font = bold_font,
		line_spacing = 0
	})
