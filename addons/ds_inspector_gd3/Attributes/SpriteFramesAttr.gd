extends BaseAttr
class_name SpriteFramesAttr

onready var label: Label = $Name
onready var texture_node: TextureRect = $Texture

var _attr: String
var _node: Node

func set_node(node: Node):
	_node = node

func set_name(name: String):
	_attr = name
	label.text = name

func set_value(value: SpriteFrames):
	# texture_node.texture = value
    if value == null:
        texture_node.texture = null
    else:
        texture_node.texture = value.get_frame(_node.animation, _node.frame)
