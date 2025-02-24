@tool
@icon("res://style_nodes/style_node_icon.png")
class_name StyleNode extends Node

## A description of this StyleNode's uses.
@export var description:String = ''

## Comma seperated list of regular expressions matched against node names, 
## @ prefixed group names, or "." to target the root node only, not any of 
## it's child nodes. If empty, the style will be applied recursively to all
## children of the root node.
@export var target:String = '':
	set(value):
		target = value
		_parse_target_string()
		_find_targets()
		
var _target_conditions:Array[Callable]
		
class TargetInfo:
	
	var nested_styles:Array[StyleNode]
	var properties_set:PackedStringArray = []
	
	func _init(nested_styles_:Array[StyleNode]):
		nested_styles = nested_styles_

var _target_types:Array[Variant]
var _target_nodes:Dictionary[Node, TargetInfo]
var _root_node:Node

var _target_configuration_warnings:PackedStringArray = []

func _get_configuration_warnings() -> PackedStringArray:
	return _target_configuration_warnings

func _init(target_types:Array[Variant]) -> void:
	_target_types = target_types
		
func _ready() -> void:
	_parse_target_string()
	_find_root_node()
	_find_targets()
	_update_targets()

func _parse_target_string() -> void:
	_target_conditions = []
	_target_configuration_warnings = []
	for part in target.split(','):
		part = part.strip_edges()
		if part == '*':
			_target_conditions.append(
				func (node:Node): 
					node == _root_node)
		elif part.begins_with('@'):
			var group_name := part.substr(1)
			_target_conditions.append(
				func (node:Node): 
					node.is_in_group(group_name))
		else:
			var regex := RegEx.new()
			var result := regex.compile(part)
			if result != OK:
				_target_configuration_warnings.append('Invalid RegEx: "%s"' % [part])
				update_configuration_warnings()
			_target_conditions.append(
				func (node:Node): 
					return regex.search(node.name) != null)
			
func _find_root_node() -> void:
	_root_node = get_parent()
	while _root_node is StyleNode:
		_root_node = _root_node.get_parent()
	prints('_find_root_node', _root_node)
	
func _find_targets() -> void:
	_target_nodes.clear()
	_find_targets_recursively(_root_node, [])
	
func _find_targets_recursively(node:Node, nested_styles:Array[StyleNode]) -> void:
	
	#prints('_find_targets_recursively', node)

	if _is_valid_target(node):
		prints('  adding target ->', node)
		_target_nodes.set(node, TargetInfo.new(nested_styles))
		
	var style_nodes := node.get_children().filter(
		func (child_node): 
			return child_node is StyleNode)
			
	var new_nested_styles:Array[StyleNode]
	if style_nodes.is_empty():
		new_nested_styles = nested_styles
	else:
		new_nested_styles = nested_styles.duplicate()
		new_nested_styles.append_array(style_nodes)
		
	for child_node in node.get_children():
		if child_node is not StyleNode and child_node.owner == _root_node.owner:
			_find_targets_recursively(child_node, new_nested_styles)
	
func _is_valid_target(node:Node) -> bool:
	for target_type in _target_types:
		if is_instance_of(node, target_type) \
			and _target_conditions.all(
				func (condition): 
					return condition.call(node)):
			return true
	return false
	
func _exit_tree() -> void:
	for node in _target_nodes.keys():
		var target_info:TargetInfo = _target_nodes.get(node)
		_update_target(node)
		for nested_style in target_info.nested_styles:
			nested_style._update_if_target(node)
		
func _style_modified() -> void:
	_update_targets()

func _update_targets() -> void:
	for node in _target_nodes.keys():
		var target_info:TargetInfo = _target_nodes.get(node)
		_update_target(node)
		for nested_style in target_info.nested_styles:
			nested_style._update_if_target(node)

func _update_if_target(node:Control) -> void:
	for child in get_children():
		if child is StyleNode:
			child._update_if_target(node)
	if _target_nodes.has(node):
		_update_target(node)
					
func _update_target(node:Control) -> void:
	assert(false, '_update_target not overriden')
	
