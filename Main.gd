extends Node2D

@export
var a: int = 0

var b: String = "hello"

func _ready():
	pass
	
func _process(_delta: float) -> void:
	rotation_degrees += _delta * 10.0
	pass
