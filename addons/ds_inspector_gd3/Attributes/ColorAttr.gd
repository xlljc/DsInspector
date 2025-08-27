extends BaseAttr
class_name ColorAttr


onready var label: Label = $Name
onready var r_line_edit: LineEdit = $VBoxContainer/HBoxContainer/RLineEdit
onready var g_line_edit: LineEdit = $VBoxContainer/HBoxContainer/GLineEdit
onready var b_line_edit: LineEdit = $VBoxContainer/HBoxContainer2/BLineEdit
onready var a_line_edit: LineEdit = $VBoxContainer/HBoxContainer2/ALineEdit

var _attr: String
var _node: Node

var _focus_flag: bool = false
var _temp_value: Color

func _ready():
	r_line_edit.connect("text_changed", self, "_on_r_text_changed")
	g_line_edit.connect("text_changed", self, "_on_g_text_changed")
	b_line_edit.connect("text_changed", self, "_on_b_text_changed")
	a_line_edit.connect("text_changed", self, "_on_a_text_changed")

	r_line_edit.connect("focus_entered", self, "_on_focus_entered")
	g_line_edit.connect("focus_entered", self, "_on_focus_entered")
	b_line_edit.connect("focus_entered", self, "_on_focus_entered")
	a_line_edit.connect("focus_entered", self, "_on_focus_entered")

	r_line_edit.connect("focus_exited", self, "_on_focus_exited")
	g_line_edit.connect("focus_exited", self, "_on_focus_exited")
	b_line_edit.connect("focus_exited", self, "_on_focus_exited")
	a_line_edit.connect("focus_exited", self, "_on_focus_exited")
	pass

func set_node(node: Node):
	_node = node

func set_name(name: String):
	_attr = name
	label.text = name

func set_value(value: Color):
	if _focus_flag:
		_temp_value = value
		return
	r_line_edit.text = str(value.r)
	g_line_edit.text = str(value.g)
	b_line_edit.text = str(value.b)
	a_line_edit.text = str(value.a)

func _on_r_text_changed(new_str: String):
	_temp_value.r = float(new_str)
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_g_text_changed(new_str: String):
	_temp_value.g= float(new_str)
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_b_text_changed(new_str: String):
	_temp_value.b = float(new_str)
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_a_text_changed(new_str: String):
	_temp_value.a = float(new_str)
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