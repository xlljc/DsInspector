extends Tree
class_name ExcludeList

export var add_btn_path: NodePath

onready var add_btn: Button = get_node(add_btn_path)
onready var debug_tool = get_node("/root/DsInspector")
var _list: Array = []
var _root_item: TreeItem
onready var _delete_icon: Texture = preload("res://addons/ds_inspector_gd3/node_icon/delete.svg")

const SAVE_PATH := "user://exclude_select.json"

func _ready():
	add_btn.connect("pressed", self, "_on_add_click")
	connect("button_pressed", self, "_on_button_pressed")
	_root_item = create_item()

	# 载入文件
	_load_exclude_list()
	pass

func has_excludeL_path(s: String) -> bool:
	return _list.has(s)

# 添加排除路径
func add_excludeL_path(s: String):
	if has_excludeL_path(s):
		return

	_list.append(s)
	var item: TreeItem = create_item(_root_item)
	item.set_text(0, s)
	item.add_button(0, _delete_icon)
	_save_exclude_list()
	pass

func _on_add_click():
	if debug_tool:
		var node: Node = debug_tool.brush._draw_node
		if node != null and is_instance_valid(node):
			var s: String = debug_tool.get_node_path(node)
			add_excludeL_path(s)
	pass

func _on_button_pressed(_item: TreeItem, _column: int, _id: int):
	var s: String = _item.get_text(0)
	_item.free()
	var index: int = _list.find(s)
	if index >= 0:
		_list.remove(index)
		_save_exclude_list()
	pass

# 保存为 JSON 文件
func _save_exclude_list():
	var file := File.new()
	if file.open(SAVE_PATH, File.WRITE) == OK:
		file.store_string(to_json(_list))
		file.close()
	else:
		print("无法保存文件到 ", SAVE_PATH)

# 加载 JSON 文件
func _load_exclude_list():
	var file := File.new()
	if file.file_exists(SAVE_PATH):
		if file.open(SAVE_PATH, File.READ) == OK:
			var content := file.get_as_text()
			file.close()
			var result = parse_json(content)
			if typeof(result) == TYPE_ARRAY:
				for s in result:
					if typeof(s) == TYPE_STRING:
						_list.append(s)
						var item: TreeItem = create_item(_root_item)
						item.set_text(0, s)
						item.add_button(0, _delete_icon)
			else:
				print("JSON 文件内容格式错误")
		else:
			print("无法打开文件 ", SAVE_PATH)
