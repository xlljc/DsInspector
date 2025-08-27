extends BaseAttr
class_name LabelAttr

onready var label: Label = $Name
onready var text: Label = $Text

var _node: Node

func set_node(node: Node):
	_node = node

func set_name(name: String):
	label.text = name

func set_value(value):
	text.text = str(value)
	text.hint_tooltip = name