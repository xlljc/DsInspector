extends Node2D


var timer: float = 0.0

func _process(delta):
	timer += delta
	if timer >= 0.5:
		timer -= 0.5;
		var n := TestNode.new()
		add_child(n)
	pass
