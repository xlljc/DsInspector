extends MarginContainer

onready var _title: Label = $HBoxContainer/Title

func set_title(title: String):
	_title.text = title
