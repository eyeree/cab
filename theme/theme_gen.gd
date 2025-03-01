@tool
class_name DefaultTheme extends ProgrammaticTheme

# https://github.com/Inspiaaa/ThemeGen

const GRID_DEFAULT_LINE_COLOR := Color(0.451, 0.071, 0.4)
const GRID_DEFAULT_FILL_COLOR := Color(0.071, 0.0, 0.078)
const GRID_HOVER_LINE_COLOR := Color(0.435, 0.0, 0.486)
const GRID_HOVER_FILL_COLOR := Color(0.231, 0.008, 0.247)
const GRID_SELECTED_LINE_COLOR := Color(0.839, 0.0, 0.929)
const GRID_SELECTED_FILL_COLOR := Color(0.312, 0.013, 0.335)
const GRID_BAD_TARGET_LINE_COLOR := Color(1.0, 0.0, 0.0)
const GRID_BAD_TARGET_FILL_COLOR := Color(0.3, 0.0, 0.0)
const GRID_NETURAL_TARGET_LINE_COLOR := Color(0.94, 0.94, 0.15)
const GRID_NETURAL_TARGET_FILL_COLOR := Color(0.227, 0.227, 0.003)
const GRID_GOOD_TARGET_LINE_COLOR := Color(0.0, 0.828, 0.0)
const GRID_GOOD_TARGET_FILL_COLOR := Color(0.106, 0.208, 0.0)

func setup():
	set_save_path("res://theme/generated/default_theme_old.tres")

func setup_major_sub_detail_panel():
	set_save_path("res://theme/generated/major_sub_detail_panel_theme_old.tres")
	set_theme_generator(define_major_sub_detail_panel_theme)

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
	
	define_style('Control', {
		font_color = GRID_SELECTED_LINE_COLOR
	})
	
	define_style('PanelContainer', {
		panel = default_panel_style
	})
	
	define_style('Label', {
		font_color = Color(0.896, 0.486, 0.98)
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
	
	define_variant_style("MajorSubDetailPanelLabel", "Label", {
		font_color = Color(0.94, 0.94, 0.15)
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
	
	define_variant_style('PlaybackControlButton', 'Button', {
		normal = stylebox_flat({
			bg_color = GRID_HOVER_FILL_COLOR,
			content_margin_ = content_margins(2)
		}),
		disabled = stylebox_flat({
			bg_color = GRID_HOVER_FILL_COLOR,
			content_margin_ = content_margins(2)
		})
	})
	
	define_variant_style('ButtonBar', 'PanelContainer', {
		panel = stylebox_flat({
			bg_color = GRID_DEFAULT_LINE_COLOR,
			content_margin_ = content_margins(4)
		})
	})

	define_variant_style('ButtonBarButton', 'Button', {
		normal = stylebox_flat({
			bg_color = GRID_HOVER_FILL_COLOR,
			content_margin_ = content_margins(2)
		}),
		disabled = stylebox_flat({
			bg_color = GRID_HOVER_FILL_COLOR,
			content_margin_ = content_margins(2)
		}),
		font_color = GRID_NETURAL_TARGET_LINE_COLOR
	})
	
	define_variant_style('ButtonBarLabel', 'Label', {
		font_color = GRID_NETURAL_TARGET_LINE_COLOR
	})
	
	define_style('Slider', {
		grabber = load("res://icon/slider_grabber.svg"),
		grabber_disabled = load("res://icon/slider_grabber_disabled.svg"),
		grabber_highlight = load("res://icon/slider_grabber_highlight.svg"),
		slider = stylebox_flat({
			bg_color = GRID_HOVER_FILL_COLOR,
			corner_radius_ = corner_radius(3),
			content_margin_top = 3,
			content_margin_bottom = 3
		}),
		grabber_area = stylebox_flat({
			bg_color = GRID_HOVER_LINE_COLOR,
			corner_radius_ = corner_radius(3),
		}),
		grabber_area_highlight = stylebox_flat({
			bg_color = GRID_HOVER_LINE_COLOR,
			corner_radius_ = corner_radius(3),
		})
	})
	
	define_style('ProgressBar', {
		background = stylebox_flat({
			bg_color = GRID_HOVER_FILL_COLOR,
			corner_radius_ = corner_radius(2),
		}),		
		fill = stylebox_flat({
			bg_color = Color(GRID_SELECTED_LINE_COLOR, 0.25),
			corner_radius_ = corner_radius(2),
			content_margin_top = 2,
			content_margin_bottom = 2
		}),		
	})
	
	define_variant_style('DimLabel', 'Label', {
		font_color = GRID_HOVER_LINE_COLOR
	})
	
	define_variant_style('StepsLabel', 'Label', {
		font_color = GRID_SELECTED_LINE_COLOR,
		font_size = 26
	})

	define_variant_style('BigLabel', 'Label', {
		font_size = 32
	})	

func define_major_sub_detail_panel_theme():
	define_style('Label', {
		font_color = GRID_NETURAL_TARGET_LINE_COLOR
	})
