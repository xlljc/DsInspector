extends BaseAttr
class_name Vector2Attr

onready var label: Label = $Name
onready var x_line_edit: LineEdit = $HBoxContainer/XLineEdit
onready var y_line_edit: LineEdit = $HBoxContainer/YLineEdit

var _attr: String
var _node: Node

var _focus_flag: bool = false
var _temp_value: Vector2

func _ready():
	x_line_edit.connect("text_changed", self, "_on_x_text_changed")
	y_line_edit.connect("text_changed", self, "_on_y_text_changed")

	x_line_edit.connect("focus_entered", self, "_on_focus_entered")
	y_line_edit.connect("focus_entered", self, "_on_focus_entered")

	x_line_edit.connect("focus_exited", self, "_on_focus_exited")
	y_line_edit.connect("focus_exited", self, "_on_focus_exited")
	pass

func set_node(node: Node):
	_node = node

func set_name(name: String):
	_attr = name
	label.text = name

func set_value(value: Vector2):
	if _focus_flag:
		_temp_value = value
		return
	x_line_edit.text = str(value.x)
	y_line_edit.text = str(value.y)

func _on_x_text_changed(new_str: String):
	_temp_value.x = float(new_str)
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_y_text_changed(new_str: String):
	_temp_value.y = float(new_str)
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