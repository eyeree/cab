@tool
@icon("res://style_nodes/style_node_icon.png")
class_name StyleNode extends Node

@export var target:String = ''
@export var description:String = ''

class TargetInfo:
	var nested_styles:Array[StyleNode]
	func _init(nested_styles_:Array[StyleNode]):
		nested_styles = nested_styles_

var _target_types:Array[Variant]
var _target_nodes:Dictionary[Node, TargetInfo]
var _root_node:Node

func _init(target_types:Array[Variant]) -> void:
	_target_types = target_types
		
func _ready() -> void:
	_find_targets()

func _find_root_node() -> void:
	_root_node = get_parent()
	while _root_node is StyleNode:
		_root_node = _root_node.get_parent()
	
func _find_targets() -> void:
	_target_nodes.clear()
	_find_targets_recursively(_root_node, [])
	
func _find_targets_recursively(node:Node, nested_styles:Array[StyleNode]) -> void:

	if _is_valid_target(node):
		_target_nodes.set(node, TargetInfo.new(nested_styles))
		
	var style_nodes:Array[StyleNode] = node.get_children().filter(
		func (child_node): 
			return child_node is StyleNode)
			
	var new_nested_styles:Array[StyleNode]
	if style_nodes.is_empty():
		new_nested_styles = nested_styles
	else:
		new_nested_styles = nested_styles.duplicate()
		new_nested_styles.append_array(style_nodes)
		
	for child_node in node.get_children():
		if child_node is not StyleNode:
			_find_targets_recursively(child_node, new_nested_styles)
	
func _is_valid_target(node:Node) -> bool:
	for target_type in _target_types:
		if is_instance_of(node, target_type):
			return true
	return false
	
func _is_target(node:Node) -> bool:
	return _target_nodes.has(node)
			
func _exit_tree() -> void:
	pass
		
func _style_modified() -> void:
	_update_targets()

func _update_targets() -> void:
	for node in _target_nodes.keys():
		var target_info:TargetInfo = _target_nodes.get(node)
		_update_target(node)
		for nested_style in target_info.nested_styles:
			if nested_style._is_target(node):
				nested_style._update_target(node)
	
func _update_target(node:Control) -> void:
	assert(false, '_update_target not overriden')
	
