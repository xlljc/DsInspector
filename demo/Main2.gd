extends Node2D


func _ready():
	# 一秒后调用 _test
	await get_tree().create_timer(1.0).timeout
	_test()

func _test():
	var window = Window.new()
	window.title = "Window中拣选"
	window.size = Vector2(500, 500)
	window.position = Vector2(100, 100)

	var sprite = Sprite2D.new()
	sprite.texture = load("res://icon.svg")
	sprite.position = Vector2(100, 100)

	var sprite2 = Sprite2D.new()
	sprite2.texture = load("res://icon.svg")
	sprite2.position = Vector2(150, 150)

	window.add_child(sprite)
	window.add_child(sprite2)
	add_child(window)
	window.popup()