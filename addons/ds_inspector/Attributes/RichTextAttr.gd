@tool
extends RichTextLabel

var type: String = "rich_text"

var _attr: String
var _node  # Node或其他Object

func set_node(node, inspector_container = null):
	_node = node

func set_attr_name(attr_name: String):
	_attr = attr_name

func set_value(value):
	text = str(value)
	tooltip_text = text
