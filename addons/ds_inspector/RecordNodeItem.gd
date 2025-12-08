@tool
extends HBoxContainer

@export
var NodeBtn: Button

@export
var DelBtn: Button

# 信号：请求删除此记录项
signal delete_requested

# 存储节点信息
var node_ref: WeakRef = null
var node_tree = null  # NodeTree 引用
var time_accumulator: float = 0.0  # 时间累积器，用于每秒更新路径

func _ready():
	# 连接按钮信号
	if NodeBtn:
		NodeBtn.pressed.connect(_on_node_button_pressed)
	if DelBtn:
		DelBtn.pressed.connect(_on_delete_button_pressed)

func _process(delta: float):
	# 累积时间，每秒更新一次路径
	time_accumulator += delta
	if time_accumulator >= 1.0:
		time_accumulator = 0.0
		_update_node_path()

# 设置节点信息
func setup_node(node: Node, tree) -> void:
	if !node or !is_instance_valid(node):
		return
	
	# 保存节点引用
	node_ref = weakref(node)
	node_tree = tree
	
	# 设置图标
	var icon_path = node_tree.icon_mapping.get_icon(node)
	if icon_path and icon_path != "":
		NodeBtn.icon = load(icon_path)

	# 更新节点路径显示
	_update_node_path()

# 更新节点路径显示
func _update_node_path() -> void:
	if !node_ref:
		return
	
	var node = node_ref.get_ref()
	if node == null or !is_instance_valid(node):
		# 节点已失效，删除此记录项
		delete_requested.emit()
		return
	
	# 更新按钮文本和提示信息
	if NodeBtn:
		# 名称 + （路径）
		NodeBtn.text = node.name + " (" + str(node.get_path()) + ")"
		
		# 设置提示信息（显示节点路径）
		NodeBtn.tooltip_text = "点击定位到: " + str(node.get_path())

# 点击节点按钮时
func _on_node_button_pressed() -> void:
	if !node_ref:
		return
	
	var node = node_ref.get_ref()
	if node == null or !is_instance_valid(node):
		# 节点已失效，删除此记录项
		delete_requested.emit()
		return
	
	# 定位到节点树中的节点
	if node_tree and node_tree.has_method("locate_selected"):
		node_tree.call_deferred("locate_selected", node)

# 点击删除按钮时
func _on_delete_button_pressed() -> void:
	delete_requested.emit()