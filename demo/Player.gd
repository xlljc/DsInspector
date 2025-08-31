extends Sprite2D

@export
var speed := 300
var vf: Vector2
var vi: Vector2i

var vf0
var vi0 = true

var flag = true

func _ready():
	vi0 = ""
	pass

func _process(delta):
	if flag:
		vi0 = Vector2(1, 2)
	else:
		vi0 = true
	var axis := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()
	position += axis * delta * speed
	pass
