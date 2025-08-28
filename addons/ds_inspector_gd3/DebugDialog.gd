extends Window

@export
var tree_path: NodePath;
@export
var exclude_list_path: NodePath;
@export
var select_btn_path: NodePath;
@export
var save_btn_path: NodePath;
@export
var delete_btn_path: NodePath;
@export
var hide_border_btn_path: NodePath;
@export
var play_btn_path: NodePath;
@export
var file_window_path: NodePath;
@export
var put_away_path: NodePath;

const SAVE_PATH := "user://ds_inspector_window.txt"

@onready
var tree: NodeTree = get_node(tree_path)
@onready
var exclude_list: ExcludeList = get_node(exclude_list_path)
@onready
var select_btn: Button = get_node(select_btn_path)
@onready
var save_btn: Button = get_node(save_btn_path)
@onready
var delete_btn: Button = get_node(delete_btn_path)
@onready
var hide_border_btn: Button = get_node(hide_border_btn_path)
@onready
var play_btn: Button = get_node(play_btn_path)
@onready
var file_window: FileDialog = get_node(file_window_path)
@onready
var put_away: Button = get_node(put_away_path)
@onready
var debug_tool = get_node("/root/DsInspector")

func _ready():
	_load_window_state()
	select_btn.pressed.connect(select_btn_click)
	delete_btn.pressed.connect(delete_btn_click)
	hide_border_btn.pressed.connect(hide_border_btn_click)
	play_btn.pressed.connect(play_btn_click)
	save_btn.pressed.connect(save_btn_click)
	close_requested.connect(do_hide)
	size_changed.connect(_on_window_resized)
	file_window.file_selected.connect(on_file_selected)
	put_away.pressed.connect(do_put_away)

# 显示弹窗
func do_show():
	if debug_tool:
		debug_tool.mask.visible = false
		debug_tool._is_open_check_ui = false
		debug_tool.check_camera()
		popup()
		tree.show_tree(debug_tool.brush._draw_node)
		# debug_tool.brush.set_draw_node(debug_tool.brush._draw_node)
		debug_tool.brush.set_show_text(false)
	pass

# 隐藏弹窗
func do_hide():
	_save_window_state()
	tree.hide_tree()
	pass

func select_btn_click():
	hide()
	if debug_tool:
		debug_tool.mask.visible = true
		debug_tool._is_open_check_ui = true

func delete_btn_click():
	tree.delete_selected();
	pass

func hide_border_btn_click():
	if debug_tool:
		debug_tool.brush.set_draw_node(null)
	pass

func play_btn_click():
	var p: bool = !get_tree().paused
	get_tree().paused = p
	play_btn.text = "继续游戏" if p else "暂停游戏"
	pass

func save_btn_click():
	if debug_tool and debug_tool.brush._draw_node != null:
		file_window.popup()
	pass

func on_file_selected(path: String):
	# print("选择文件" + path)
	if debug_tool:
		var node: Node = debug_tool.brush._draw_node
		if node != null and is_instance_valid(node):
			save_node_as_scene(node, path)
	pass

func do_put_away():
	_each_and_put_away(tree.get_root())
	pass

func _each_and_put_away(tree_item: TreeItem):
	# tree_item.collapsed = false
	# var ch: TreeItem = tree_item.get_children()
	# while ch != null:
	# 	ch.collapsed = true
	# 	_each_and_put_away(ch)
	# 	ch = ch.get_next()
	# pass

	var ch := tree_item.get_children()
	for item in ch:
		item.collapsed = true
		_each_and_put_away(item)
	pass

func save_node_as_scene(node: Node, path: String) -> void:
	var o: Node = node.owner
	node.owner = null
	_recursion_set_owner(node, node)
	var scene: PackedScene = PackedScene.new()
	var result: int = scene.pack(node)
	if result != OK:
		print("打包失败，错误码：", result)
		node.owner = o
		return
	
	var _err: int = ResourceSaver.save(scene, path)
	if _err == OK:
		print("保存成功: ", path)
	else:
		print("保存失败，错误码：", _err)
	node.owner = o

func _recursion_set_owner(node: Node, owner: Node):
	for ch in node.get_children():
		ch.owner = owner
		_recursion_set_owner(ch, owner)

# 当窗口大小改变时保存状态
func _on_window_resized():
	_save_window_state()

# 保存窗口状态（位置和大小）
func _save_window_state():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		var data := {
			"position": position,
			"size": size
		}
		file.store_string(var_to_str(data))
		file.close()
	else:
		print("无法保存窗口状态到 ", SAVE_PATH)

# 加载窗口状态（位置和大小）
func _load_window_state():
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null:
			var content := file.get_as_text()
			file.close()
			var data := str_to_var(content)
			if data is Dictionary:
				if data.has("position") and data.has("size"):
					var dataPos: Vector2 = data.position
					var dataSize: Vector2 = data.size
					
					# 确保窗口在屏幕范围内
					var clamped_pos := _clamp_window_to_screen(dataPos, dataSize)
					position = clamped_pos
					size = dataSize
					
					# 如果位置被修正，保存回配置文件
					if clamped_pos != dataPos:
						call_deferred("_save_window_state")

# 确保窗口在屏幕范围内
func _clamp_window_to_screen(pos: Vector2, size: Vector2) -> Vector2:
	var vp := get_viewport().get_visible_rect().size
	# 确保窗口不会超出屏幕边界
	pos.x = clamp(pos.x, 0, max(0, vp.x - size.x))
	pos.y = clamp(pos.y, 0, max(0, vp.y - size.y))
	return pos
