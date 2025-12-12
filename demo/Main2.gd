extends Node2D

@export
var open_window_button: Button

@export
var window_scene: PackedScene

func _ready():
	# 绑定按钮点击事件
	open_window_button.pressed.connect(_on_open_window_button_pressed)

func _on_open_window_button_pressed():
	var window = window_scene.instantiate()
	window.position = Vector2(100, 100)
	add_child(window)
	window.popup()