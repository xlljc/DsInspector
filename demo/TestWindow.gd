extends Window

@export
var test_button: Button

func _ready():
	test_button.pressed.connect(_on_test_button_pressed)
	close_requested.connect(_on_close_requested)

func _on_test_button_pressed():
	print("test_button pressed")

func _on_close_requested():
	queue_free()