@tool
extends TextureRect

var type: String = "sprite_frames"

var _attr: String
var _node  # Node或其他Object

func set_node(node, inspector_container = null):
	_node = node

func set_attr_name(attr_name: String):
	_attr = attr_name

func set_value(value):
	if value == null:
		texture = null
	elif not value is SpriteFrames:
		return
	else:
		texture = value.get_frame_texture(_node.animation, _node.frame)
