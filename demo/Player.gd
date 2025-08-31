extends Sprite2D

@export
var speed := 300
var vf: Vector2
var vi: Vector2i
var v3: Vector3
var v3i: Vector3i
var r: Rect2
var ri: Rect2i

var f: float

var vf0
var vi0 = true

func _ready():
	vi0 = ""
	pass

func _process(delta):
	var axis := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()
	position += axis * delta * speed
	pass
