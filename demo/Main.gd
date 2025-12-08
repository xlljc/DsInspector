extends Node2D

class TestData:
	var int_value: int = 0
	var float_value: float = 0.0
	var string_value: String = "Hello"
	var vector3_value: Vector3 = Vector3.ZERO
	var color_value: Color = Color.WHITE

var timer: float = 0.0
var arr = [1, 2, 3, 4, 5]
var arr2: Array[int] = [1, 2, 3, 4, 5]
var data: TestData = TestData.new()

func _ready():
	# get_viewport().gui_embed_subwindows = false
	DsInspector.add_cheat_button_callable("测试作弊", _on_cheat_button_pressed)
	pass

func _on_cheat_button_pressed():
	print("作弊按钮被按下")

func _process(delta):
	timer += delta
	if timer >= 0.5:
		timer -= 0.5;
		var n := DsTestNode.new()
		add_child(n)
	pass
