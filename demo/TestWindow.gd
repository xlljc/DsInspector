extends Window

func _ready():
	close_requested.connect(_on_close_requested)

func _on_close_requested():
	queue_free()