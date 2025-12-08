@tool
extends BaseAttr


@export
var label: Label
@export
var text: Label

var type: String = "label"

var _node: Node

func set_node(node: Node):
	_node = node

func set_title(name: String):
	label.text = name

func set_value(value):
	text.text = str(value)
	text.tooltip_text = name
