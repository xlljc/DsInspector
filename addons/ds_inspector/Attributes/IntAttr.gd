@tool
extends LineEdit

var type: String = "int"

var _attr: String
var _node: Node

var _focus_flag: bool = false
var _temp_value: int

func _ready():
	text_changed.connect(_on_text_changed)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	pass

func set_node(node: Node):
	_node = node

func set_attr_name(attr_name: String):
	_attr = attr_name

func set_value(value):
	if not value is int:
		return
	if _focus_flag:
		_temp_value = value
		return
	text = str(value)

func _on_text_changed(new_str: String):
	if new_str == "":
		_temp_value = 0
	else:
		var parsed = int(new_str)
		_temp_value = parsed
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_focus_entered():
	_focus_flag = true
	pass

func _on_focus_exited():
	_focus_flag = false
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)
	pass
