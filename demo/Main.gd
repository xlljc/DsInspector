extends Node2D


var timer: float = 0.0

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
		var n := TestNode.new()
		add_child(n)
	pass
