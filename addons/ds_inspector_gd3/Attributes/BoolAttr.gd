extends BaseAttr
class_name BoolAttr

onready var label: Label = $Name
onready var check_box: CheckBox = $CheckBox

var _attr: String
var _node: Node

func _ready():
	check_box.connect("pressed", self, "_on_pressed")
	pass

func set_node(node: Node):
	_node = node

func set_name(name: String):
	_attr = name
	label.text = name

func set_value(value: bool):
	check_box.pressed = value

func _on_pressed():
	_node.set(_attr, check_box.pressed)