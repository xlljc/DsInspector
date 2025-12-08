extends Node2D

class TestData:
	var int_value: int = 0
	var float_value: float = 0.0
	var string_value: String = "Hello"
	var vector3_value: Vector3 = Vector3.ZERO
	var color_value: Color = Color.WHITE
	var ch_data

var timer: float = 0.0
var timer2: float = 0.0

var arr = [1, 2, 3, 4, 5, Color.RED]
var arr2: Array[int] = [1, 2, 3, 4, 5]
var data = TestData.new()
var data2 = null
var data3 = null
var data4 = {
	"a": 1,
	"b": 2,
	"c": 3,
	"d": 4,
	"e": 5,
	"f": 6,
}

func _ready():
	# get_viewport().gui_embed_subwindows = false
	DsInspector.add_cheat_button_callable("测试作弊", _on_cheat_button_pressed)
	data.ch_data = TestData.new()
	for i in range(30):
		arr2.push_back(i)
	pass

func _on_cheat_button_pressed():
	print("作弊按钮被按下")

func _process(delta):
	timer += delta
	if timer >= 0.5:
		timer -= 0.5;
		var n := DsTestNode.new()
		add_child(n)
	timer2 += delta
	data.float_value += delta
	data.ch_data.float_value += delta * 2
	arr[0] += delta
	if timer2 >= 1:
		timer2 -= 1;
		data3 = self
		# arr[1] = Node2D.new()
		# arr2.remove_at(arr2.size() - 1)
		# data2 = Node2D.new()
		data.ch_data.ch_data = TestData.new()
	pass
