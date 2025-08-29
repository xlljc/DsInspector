extends VBoxContainer
class_name InspectorContainer

@export
var update_time: float = 0.2 # 更新时间

var _curr_node: Node
var _timer: float = 0

const flag: int = PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_EDITOR
var _attr_list: Array = [] # value: AttrItem

@onready
var line: PackedScene = preload("res://addons/ds_inspector/Attributes/Line.tscn")
@onready
var label_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/LabelAttr.tscn")
@onready
var bool_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/BoolAttr.tscn")
@onready
var number_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/NumberAttr.tscn")
@onready
var vector2_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector2Attr.tscn")
@onready
var color_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/ColorAttr.tscn")
@onready
var rect_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/RectAttr.tscn")
@onready
var string_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/StringAttr.tscn")
@onready
var texture_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/TextureAttr.tscn")
@onready
var sprite_frames_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/SpriteFramesAttr.tscn")

class AttrItem:
	var attr: BaseAttr
	var name: String
	var usage: int
	var type: int
	func _init(_attr: BaseAttr, _name: String, _usage: int, _type: int):
		attr = _attr
		name = _name
		usage = _usage
		type = _type
		pass
	pass

func _ready():

	pass

func _process(delta):
	if _curr_node:
		if !is_instance_valid(_curr_node):
			_clear_node_attr()
			pass
		_timer += delta
		if _timer > update_time:
			_timer = 0
			_update_node_attr()
		pass

func set_view_node(node: Node):
	_clear_node_attr()
	if node == null or !is_instance_valid(node):
		return
	_curr_node = node
	_init_node_attr()
	_update_node_attr()
	pass

func _init_node_attr():
	var title = line.instantiate();
	add_child(title)
	title.set_title("基础属性")

	# 节点名称
	_create_label_attr(_curr_node, "名称：", _curr_node.name)
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
	
	var props = _curr_node.get_property_list()

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

func _create_node_attr(prop) -> AttrItem:
	var v := _curr_node.get(prop.name)
	var attr: BaseAttr

	# ------------- 特殊处理 -----------------
	if _curr_node is AnimatedSprite2D:
		if prop.name == "sprite_frames":
			attr = sprite_frames_attr.instantiate()
	# ---------------------------------------
	if attr == null:
		if v == null:
			attr = label_attr.instantiate()
		else:
			match typeof(v):
				TYPE_BOOL:
					attr = bool_attr.instantiate()
				TYPE_INT:
					attr = number_attr.instantiate()
				TYPE_FLOAT:
					attr = number_attr.instantiate()
				TYPE_VECTOR2:
					attr = vector2_attr.instantiate()
				TYPE_COLOR:
					attr = color_attr.instantiate()
				TYPE_RECT2:
					attr = rect_attr.instantiate()
				TYPE_STRING:
					attr = string_attr.instantiate()
				TYPE_OBJECT:
					if v is Texture2D:
						attr = texture_attr.instantiate()
					else:
						attr = label_attr.instantiate()
				_:
					attr = label_attr.instantiate()
	add_child(attr)

	attr.set_node(_curr_node)
	attr.set_title(prop.name)
	attr.set_value(v)
	# print(prop.name, "   ", typeof(v))
	return AttrItem.new(attr, prop.name, prop.usage, prop.type)

func _create_label_attr(node: Node, title: String, value: String) -> void:
	var attr: LabelAttr = label_attr.instantiate()
	add_child(attr)
	attr.set_node(node)
	attr.set_title(title)
	attr.set_value(value)

func _update_node_attr():
	for item in _attr_list:
		item.attr.set_value(_curr_node.get(item.name))
	pass

func _clear_node_attr():
	_curr_node = null
	_attr_list.clear()
	for child in get_children():
			child.queue_free()
	pass
