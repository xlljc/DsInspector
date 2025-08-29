extends Sprite2D

@export
var speed := 300

func _ready():
	pass

func _process(delta):
	var axis := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()
	position += axis * delta * speed
	pass
