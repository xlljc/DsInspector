@tool
extends Tree
class_name DsCollectList

@export
var add_btn_path: NodePath

@export
var debug_tool_path: NodePath

@onready
var add_btn: Button = get_node(add_btn_path)
@onready
var debug_tool = get_node(debug_tool_path)
var _list: Array = []
var _root_item: TreeItem
var _is_button_clicked: bool = false  # 标记是否刚刚点击了按钮
@onready
var _delete_icon: Texture = preload("res://addons/ds_inspector/icon/delete.svg")

func _ready():
	add_btn.pressed.connect(_on_add_click)
	item_selected.connect(_on_item_selected)
	item_activated.connect(_on_item_activated)  # 添加激活信号，用于处理已选中项的点击
	button_clicked.connect(_on_button_pressed)
	_root_item = create_item()

	# 载入文件
	_load_collect_list()
	pass

func has_collect_path(s: String) -> bool:
	if debug_tool.save_config:
		return debug_tool.save_config.has_collect_path(s)
	return _list.has(s)

# 添加收集路径
func add_collect_path(s: String) -> void:
	if has_collect_path(s):
		return

	_list.append(s)
	var item: TreeItem = create_item(_root_item)
	item.set_text(0, s)
	item.add_button(0, _delete_icon)

	if debug_tool.save_config:
		debug_tool.save_config.add_collect_path(s)
	pass

func _on_add_click():
	if debug_tool:
		var node: Node = debug_tool.brush.get_draw_node()
		if node != null and is_instance_valid(node):
			var s: String = debug_tool.get_node_path(node)
			add_collect_path(s)
	pass

func _on_item_selected():
	# 如果刚刚点击了按钮，不执行跳转
	if _is_button_clicked:
		_is_button_clicked = false
		return
	
	var selected_item: TreeItem = get_selected()
	if selected_item:
		var path: String = selected_item.get_text(0)
		_jump_to_node(path)
	pass

func _on_item_activated():
	# 处理项目激活（双击或单击已选中项）
	# 如果刚刚点击了按钮，不执行跳转
	if _is_button_clicked:
		_is_button_clicked = false
		return
	
	var selected_item: TreeItem = get_selected()
	if selected_item:
		var path: String = selected_item.get_text(0)
		_jump_to_node(path)
	pass

func _gui_input(event: InputEvent) -> void:
	# 检测鼠标点击，确保每次点击都触发跳转
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			# 如果刚刚点击了按钮，不执行跳转
			if _is_button_clicked:
				_is_button_clicked = false
				return
			
			# 获取鼠标位置下的项目
			var clicked_item: TreeItem = get_item_at_position(mouse_event.position)
			if clicked_item and clicked_item != _root_item:
				# 检查是否是同一个项目（已选中的项目）
				var selected_item: TreeItem = get_selected()
				if clicked_item == selected_item:
					# 即使已经选中，也触发跳转
					var path: String = clicked_item.get_text(0)
					_jump_to_node(path)
	pass

func _on_button_pressed(item: TreeItem, column: int, id: int, mouse_button_index: int):
	_is_button_clicked = true  # 标记刚刚点击了按钮
	var s: String = item.get_text(0)
	item.free()
	var index: int = _list.find(s)
	if index >= 0:
		_list.remove_at(index)
		if debug_tool.save_config:
			debug_tool.save_config.remove_collect_path(s)
	pass

# 跳转到指定路径的节点
func _jump_to_node(path: String) -> void:
	if path.is_empty():
		return
	
	var node: Node = null
	
	# get_node_path 返回的是相对路径（从根节点的子节点开始）
	# 例如 "Main/Player" 表示根节点的子节点 Main 下的 Player 节点
	# 我们需要遍历根节点的所有子节点，尝试找到匹配的路径
	var root: Node = get_tree().root
	
	# 方法1: 尝试从每个子节点开始查找
	for child in root.get_children():
		# 如果路径正好是子节点的名称
		if path == child.name:
			node = child
			break
		
		# 如果路径以子节点名称开头，尝试从该子节点查找
		if path.begins_with(child.name + "/"):
			var sub_path: String = path.substr(child.name.length() + 1)
			var test_node: Node = child.get_node_or_null(NodePath(sub_path))
			if test_node != null and is_instance_valid(test_node):
				node = test_node
				break
		
		# 尝试直接使用完整路径查找
		var test_node: Node = child.get_node_or_null(NodePath(path))
		if test_node != null and is_instance_valid(test_node):
			node = test_node
			break
	
	# 方法2: 如果还是找不到，通过路径字符串匹配查找（遍历整个场景树）
	if node == null or !is_instance_valid(node):
		node = _find_node_by_path_string(root, path)
	
	if node != null and is_instance_valid(node):
		# 找到节点，跳转
		var tree: DsNodeTree = debug_tool.window.tree
		if tree:
			tree.locate_selected(node)
			debug_tool.brush.set_draw_node(node)
			debug_tool.inspector.set_view_node(node)
	else:
		# 没有找到节点，输出日志
		debug_tool.tips.text = "无法找到路径为 '" + path + "' 的节点"
		debug_tool.tips_anim.play("show")
		print("CollectList: 无法找到路径为 '", path, "' 的节点")
	pass

# 递归查找节点（通过路径字符串匹配）
func _find_node_by_path_string(root: Node, target_path: String) -> Node:
	if root == null:
		return null
	
	# 跳过根节点本身，只检查子节点
	for child in root.get_children():
		# 获取子节点的相对路径（类似 get_node_path 的格式）
		var current_path: String = _get_relative_path(child)
		if current_path == target_path:
			return child
		
		# 递归查找子节点
		var found: Node = _find_node_by_path_string(child, target_path)
		if found != null:
			return found
	
	return null

# 获取节点的相对路径（类似 get_node_path 的格式）
func _get_relative_path(node: Node) -> String:
	if node == null:
		return ""
	
	var s: String = ""
	var current: Node = node
	while current != null:
		var p = current.get_parent()
		if p == null or p == get_tree().root:
			break
		if s.length() > 0:
			s = current.name + "/" + s
		else:
			s = current.name
		current = p
	return s

# 加载收集列表
func _load_collect_list():
	if debug_tool.save_config:
		_list = debug_tool.save_config.get_collect_list()
		for s in _list:
			var item: TreeItem = create_item(_root_item)
			item.set_text(0, s)
			item.add_button(0, _delete_icon)
