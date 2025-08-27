extends BaseAttr
class_name TextureAttr

onready var label: Label = $Name
onready var texture_node: TextureRect = $Texture

var _attr: String
var _node: Node

func set_node(node: Node):
	_node = node

func set_name(name: String):
	_attr = name
	label.text = name

func set_value(value: Texture):
	texture_node.texture = value
