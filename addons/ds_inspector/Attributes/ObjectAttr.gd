@tool
extends VBoxContainer

@export
var expand_icon_tex: Texture2D
@export
var collapse_icon_tex: Texture2D
@export
var expand_btn: Button

var type: String = "object"

var _node: Node
var _attr: String
var _value

func set_node(node: Node):
	_node = node
	pass

func set_attr_name(attr_name: String):
	_attr = attr_name
	pass

func set_value(value):
	_value = value
	pass