@tool
extends TextureRect

var type: String = "texture"

var _attr: String
var _node: Node

func set_node(node: Node):
	_node = node

func set_attr_name(attr_name: String):
	_attr = attr_name

func set_value(value):
	if value == null:
		texture = null
		return
	elif not value is Texture:
		return
	texture = value
