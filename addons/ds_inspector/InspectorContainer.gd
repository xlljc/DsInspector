@tool
extends VBoxContainer
class_name DsInspectorContainer

@export
var update_time: float = 0.2 # 更新时间
@export
var filtr_input: LineEdit # 过滤属性输入框
@export
var debug_tool: CanvasLayer

var _curr_node: Node
var _has_node: bool = false
var _timer: float = 0

const flag: int = PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_EDITOR
var _attr_list: Array = [] # value: AttrItem

# 历史记录相关
var _history: Array[WeakRef] = [] # 存储节点的弱引用
var _history_index: int = -1 # 当前历史索引
var _is_navigating_history: bool = false # 标记是否正在浏览历史
# 限制历史记录数量（可选，防止无限增长）
var max_history = 50

@onready
var attr_item: PackedScene = preload("res://addons/ds_inspector/Attributes/AttrItem.tscn")

@onready
var line: PackedScene = preload("res://addons/ds_inspector/Attributes/Line.tscn")
@onready
var label_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/LabelAttr.tscn")
@onready
var rich_text_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/RichTextAttr.tscn")
@onready
var bool_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/BoolAttr.tscn")
@onready
var float_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/FloatAttr.tscn")
@onready
var int_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/IntAttr.tscn")
@onready
var vector2_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector2Attr.tscn")
@onready
var vector2I_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector2IAttr.tscn")
@onready
var vector3_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector3Attr.tscn") # 新增
@onready
var vector3I_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector3IAttr.tscn") # 新增
@onready
var color_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/ColorAttr.tscn")
@onready
var rect_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/RectAttr.tscn")
@onready
var recti_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/RectIAttr.tscn")
@onready
var string_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/StringAttr.tscn")
@onready
var texture_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/TextureAttr.tscn")
@onready
var sprite_frames_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/SpriteFramesAttr.tscn")
@onready
var enum_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/EnumAttr.tscn")
@onready
var object_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/ObjectAttr.tscn")
@onready
var array_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/ArrayAttr.tscn")
@onready
var map_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/MapAttr.tscn")

class AttrItem:
	var attr: DsAttrItem
	var name: String
	var usage: int
	var type: int
	func _init(_attr: DsAttrItem, _name: String, _usage: int, _type: int):
		attr = _attr
		name = _name
		usage = _usage
		type = _type
		pass
	pass

func _ready():
	if filtr_input:
		filtr_input.text_changed.connect(_on_filter_text_changed)
	pass

func _process(delta):
	if _has_node and is_visible_in_tree():
		if _curr_node == null or !is_instance_valid(_curr_node) or !_curr_node.is_inside_tree():
			_clear_node_attr()
			pass
		_timer += delta
		if _timer > update_time:
			_timer = 0
			_update_node_attr()
			_clean_invalid_history() # 清理无效的历史节点
		pass

func set_view_node(node: Node):
	_clear_node_attr()
	if node == null or !is_instance_valid(node):
		_update_history_buttons()
		return
	
	# 如果不是在浏览历史，则添加到历史记录
	if !_is_navigating_history:
		_add_to_history(node)
	
	_curr_node = node
	_has_node = true
	_init_node_attr()
	_update_node_attr()
	
	# 应用当前的过滤条件
	if filtr_input and filtr_input.text != "":
		_filter_attributes(filtr_input.text)
	
	_update_history_buttons()
	pass

func _init_node_attr():
	var title = line.instantiate();
	add_child(title)
	title.set_title("基础属性")

	# 节点名称
	_create_label_attr(_curr_node, "名称：", _curr_node.name)
	
	# 节点类型
	_create_label_attr(_curr_node, "类型：", _curr_node.get_class())
	
	# _curr_node.name
	var path: String = ""
	var curr: Node = _curr_node
	while curr != null:
		if path.length() == 0:
			path = curr.name
		else:
			path = curr.name + "/" + path
		curr = curr.get_parent()
	
	_create_label_attr(_curr_node, "路径：", path)
	
	if _curr_node.scene_file_path != "":
		_create_label_attr(_curr_node, "场景：", _curr_node.scene_file_path)
	
	var props: Array[Dictionary] = _curr_node.get_property_list()

	var script: Script = _curr_node.get_script()
	if script != null:
		_create_label_attr(_curr_node, "脚本：", script.get_path())

		var title2 = line.instantiate();
		add_child(title2)
		title2.set_title("脚本导出属性")
		
		for prop in props:
			if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and prop.usage & PROPERTY_USAGE_EDITOR: # PROPERTY_USAGE_STORAGE   PROPERTY_USAGE_SCRIPT_VARIABLE
				_attr_list.append(_create_node_attr(prop))
		
		var title4 = line.instantiate();
		add_child(title4)
		title4.set_title("脚本属性")
		
		for prop in props:
			if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not prop.usage & PROPERTY_USAGE_EDITOR: # PROPERTY_USAGE_STORAGE   PROPERTY_USAGE_SCRIPT_VARIABLE
				_attr_list.append(_create_node_attr(prop))
	
	var title3 = line.instantiate();
	add_child(title3)
	title3.set_title("内置属性")

	for prop in props:
		if prop.usage & PROPERTY_USAGE_EDITOR and not prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			_attr_list.append(_create_node_attr(prop))
			
	var c: Control = Control.new()
	c.custom_minimum_size = Vector2(0, 100)
	add_child(c)
	pass

func _create_node_attr(prop: Dictionary) -> AttrItem:
	var attr: DsAttrItem = attr_item.instantiate()

	attr.set_node(_curr_node, self)
	attr.set_attr(prop)
	add_child(attr)
	
	return AttrItem.new(attr, prop.name, prop.usage, prop.type)

func _create_label_attr(node: Node, title: String, value: String) -> void:
	var attr: DsAttrItem = attr_item.instantiate()
	attr.label.text = title
	attr.set_node(node, self)
	attr.set_attr_node(rich_text_attr.instantiate())
	attr.set_value(value)
	add_child(attr)

func _update_node_attr():
	for item in _attr_list:
		item.attr.set_value(_curr_node.get(item.name))
	pass

func _clear_node_attr():
	_curr_node = null
	_has_node = false
	_attr_list.clear()
	for child in get_children():
			child.queue_free()
	pass

func _on_filter_text_changed(new_text: String):
	_filter_attributes(new_text)
	pass

func _filter_attributes(filter_text: String):
	if filter_text == "":
		# 显示所有属性
		for item in _attr_list:
			item.attr.visible = true
	else:
		# 按"|"分割多个搜索词
		var filter_parts = filter_text.split("|")
		var filter_lowers: Array[String] = []
		for part in filter_parts:
			var trimmed = part.strip_edges()
			if trimmed != "":
				filter_lowers.append(trimmed.to_lower().replace("_", ""))
		
		# 过滤属性（不区分大小写，忽略下划线）
		for item in _attr_list:
			var name_lower = item.name.to_lower().replace("_", "")
			var matches = false
			# 检查是否匹配任何一个搜索词（OR逻辑）
			for filter_lower in filter_lowers:
				if name_lower.contains(filter_lower):
					matches = true
					break
			item.attr.visible = matches
	pass

# ==================== 历史记录功能 ====================

# 添加节点到历史记录
func _add_to_history(node: Node):
	if node == null or !is_instance_valid(node):
		return
	
	# 检查是否和当前历史位置的节点相同
	if _history_index >= 0 and _history_index < _history.size():
		var current_ref = _history[_history_index]
		var current_node = current_ref.get_ref()
		if current_node == node:
			return # 相同节点，不添加
	
	# 如果当前不在历史末尾，删除当前位置之后的所有历史
	if _history_index < _history.size() - 1:
		_history.resize(_history_index + 1)
	
	# 添加新节点到历史
	_history.append(weakref(node))
	_history_index = _history.size() - 1
	
	if _history.size() > max_history:
		_history.remove_at(0)
		_history_index = _history.size() - 1

# 清理无效的历史节点
func _clean_invalid_history():
	var i = 0
	while i < _history.size():
		var node_ref = _history[i]
		var node = node_ref.get_ref()
		if node == null or !is_instance_valid(node):
			_history.remove_at(i)
			# 调整当前索引
			if _history_index >= i:
				_history_index -= 1
		else:
			i += 1
	
	# 确保索引有效
	if _history.size() == 0:
		_history_index = -1
	elif _history_index >= _history.size():
		_history_index = _history.size() - 1
	elif _history_index < 0 and _history.size() > 0:
		_history_index = 0
	
	_update_history_buttons()

# 导航到上一个节点
func navigate_prev():
	if !can_navigate_prev():
		return
	
	_history_index -= 1
	var node_ref = _history[_history_index]
	var node = node_ref.get_ref()
	
	if node != null and is_instance_valid(node):
		_is_navigating_history = true
		set_view_node(node)
		_is_navigating_history = false
		
		# 更新树的选择
		if debug_tool and debug_tool.window and debug_tool.window.tree:
			debug_tool.window.tree.call_deferred("locate_selected", node)
	else:
		# 节点已失效，清理并重试
		_clean_invalid_history()

# 导航到下一个节点
func navigate_next():
	if !can_navigate_next():
		return
	
	_history_index += 1
	var node_ref = _history[_history_index]
	var node = node_ref.get_ref()
	
	if node != null and is_instance_valid(node):
		_is_navigating_history = true
		set_view_node(node)
		_is_navigating_history = false
		
		# 更新树的选择
		if debug_tool and debug_tool.window and debug_tool.window.tree:
			debug_tool.window.tree.call_deferred("locate_selected", node)
	else:
		# 节点已失效，清理并重试
		_clean_invalid_history()

# 检查是否可以导航到上一个
func can_navigate_prev() -> bool:
	return _history_index > 0

# 检查是否可以导航到下一个
func can_navigate_next() -> bool:
	return _history_index < _history.size() - 1

# 更新历史按钮的启用状态
func _update_history_buttons():
	if debug_tool and debug_tool.window:
		if debug_tool.window.prev_btn:
			debug_tool.window.prev_btn.disabled = !can_navigate_prev()
		if debug_tool.window.next_btn:
			debug_tool.window.next_btn.disabled = !can_navigate_next()
