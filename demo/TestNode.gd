extends Node2D
class_name DsTestNode

@export
var test: float = 0;
@export
var test2: String;
var test3: int = 0

# 到期删除
@onready
var timer: float = randf_range(2.0, 5.0)


func _process(delta):
	timer -= delta
	if timer <= 0:
		queue_free()  # 删除节点
		return
