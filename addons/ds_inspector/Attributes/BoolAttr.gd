@tool
extends CheckBox

var type: String = "bool"

var _attr: String
var _node  # Node或其他Object

func _ready():
	pressed.connect(_on_pressed)
	pass

func set_node(node, inspector_container = null):
	_node = node

func set_attr_name(attr_name: String):
	_attr = attr_name

func set_value(value):
	if not value is bool:
		return
	button_pressed = value

func _on_pressed():
	_node.set(_attr, button_pressed)
