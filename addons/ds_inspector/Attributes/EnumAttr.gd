@tool
extends OptionButton

var type: String = "enum"

var _attr: String
var _node  # Node或其他Object

func _ready():
	item_selected.connect(_on_item_selected)
	pass

func set_node(node, _inspector_container = null):
	_node = node

func set_enum_options(options: String):
	clear()
	var opts = options.split(",")
	for i in opts.size():
		if opts[i].contains(":"):
			add_item(opts[i].get_slice(":", 0), int(opts[i].get_slice(":", 1)))
		else:
			add_item(opts[i])
	pass

func set_attr_name(attr_name: String):
	_attr = attr_name

func set_value(value):
	if not value is int:
		return
	if not has_focus():
		select(get_item_index(value))
	pass

func _on_item_selected(index: int):
	_node.set(_attr, index)
	pass
