@tool
extends HBoxContainer

@export
var delete_btn: Button

func add_target_node(node: Node):
	add_child(node)
	move_child(node, 0)