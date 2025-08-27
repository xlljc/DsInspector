extends BaseAttr
class_name NumberAttr

onready var label: Label = $Name
onready var line_edit: LineEdit = $LineEdit

var _attr: String
var _node: Node

var _focus_flag: bool = false
var _temp_value: float

func _ready():
	line_edit.connect("text_changed", self, "_on_text_changed")
	line_edit.connect("focus_entered", self, "_on_focus_entered")
	line_edit.connect("focus_exited", self, "_on_focus_exited")
	pass

func set_node(node: Node):
	_node = node

func set_name(name: String):
	_attr = name
	label.text = name

func set_value(value: float):
	if _focus_flag:
		_temp_value = value
		return
	line_edit.text = str(value)

func _on_text_changed(new_str: String):
	_temp_value = float(new_str)
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
