extends Node2D

@export
var a: int = 0

var b: String = "hello"

func _ready():
	DsInspector.add_cheat_button_callable("测试按钮", on_test_button_click)
	pass

func _process(_delta: float) -> void:
	rotation_degrees += _delta * 10.0
	pass

func on_test_button_click():
	print("Test button clicked!")
	pass
