extends BaseAttr
class_name TextureAttr

@export
var label: Label
@export
var texture_node: TextureRect

var _attr: String
var _node: Node

func set_node(node: Node):
	_node = node

func set_title(name: String):
	_attr = name
	label.text = name

func set_value(value: Texture):
	texture_node.texture = value
