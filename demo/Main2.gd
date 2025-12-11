extends Node2D

@export
var window_scene: PackedScene

func _ready():
	# 一秒后调用 _test
	await get_tree().create_timer(1.0).timeout
	_test()

func _test():
	var window = window_scene.instantiate()
	add_child(window)
	window.popup()