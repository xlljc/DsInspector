@tool
extends Label

var type: String = "label"

var _node: Node

func set_node(node: Node):
	_node = node

func set_attr_name(attr_name: String):
	text = attr_name

func set_value(value):
	text = str(value)
	tooltip_text = text
