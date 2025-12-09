@tool
extends VBoxContainer

@export
var record_node_item_scene: PackedScene


@export
var tip_label: Label

@export
var node_tree: DsNodeTree

# 存储已记录的节点信息
var recorded_nodes: Dictionary = {}  # key: node_path, value: {node_ref: WeakRef, item: RecordNodeItem}

func _ready():
	# 启用拖放接收功能
	set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)
	# 初始化 tip_label 的可见性
	_update_tip_label_visibility()

# 判断是否可以接收拖放的数据
func _can_drop_data_fw(_position: Vector2, drag_data: Variant) -> bool:
	if typeof(drag_data) != TYPE_DICTIONARY:
		return false
	
	# 检查是否有 node_ref
	if !drag_data.has("node_ref"):
		return false
	
	# 从 weakref 获取节点
	var node_ref: WeakRef = drag_data["node_ref"]
	var dragged_node = node_ref.get_ref()
	
	# 检查节点是否有效
	if dragged_node == null or !is_instance_valid(dragged_node):
		return false
	
	# 不允许记录根节点
	if dragged_node == get_tree().root:
		return false
	
	return true

# 执行拖放操作
func _drop_data_fw(_position: Vector2, drag_data: Variant) -> void:
	if typeof(drag_data) != TYPE_DICTIONARY:
		return
	
	if !drag_data.has("node_ref"):
		return
	
	# 从 weakref 获取节点
	var node_ref: WeakRef = drag_data["node_ref"]
	var dragged_node = node_ref.get_ref()
	
	# 检查节点是否有效
	if dragged_node == null or !is_instance_valid(dragged_node):
		return
	
	# 检查是否已经记录过这个节点
	var node_path: String = str(dragged_node.get_path())
	if recorded_nodes.has(node_path):
		print("节点已经被记录: ", dragged_node.name)
		return
	
	# 创建记录项
	_add_record_item(dragged_node)

# 添加记录项
func _add_record_item(node: Node) -> void:
	if !record_node_item_scene:
		push_error("RecordContainer: record_node_item_scene 未设置！")
		return
	
	# 实例化记录项
	var record_item = record_node_item_scene.instantiate()
	add_child(record_item)
	
	# 设置节点信息
	record_item.setup_node(node, node_tree)
	
	# 连接删除信号
	record_item.delete_requested.connect(_on_record_item_deleted.bind(record_item))
	
	# 记录到字典中
	var node_path: String = str(node.get_path())
	recorded_nodes[node_path] = {
		"node_ref": weakref(node),
		"item": record_item
	}
	
	# 更新 tip_label 的可见性
	_update_tip_label_visibility()

# 当记录项被删除时
func _on_record_item_deleted(record_item) -> void:
	# 从字典中移除
	for node_path in recorded_nodes.keys():
		if recorded_nodes[node_path]["item"] == record_item:
			recorded_nodes.erase(node_path)
			break
	
	# 删除记录项节点
	record_item.queue_free()
	
	# 更新 tip_label 的可见性
	_update_tip_label_visibility()

# 更新 tip_label 的可见性
func _update_tip_label_visibility() -> void:
	if tip_label:
		# 当节点数量为0时显示，大于0时隐藏
		tip_label.visible = recorded_nodes.size() == 0

# 清理已失效的节点记录
func _process(_delta: float) -> void:
	# 定期检查并清理失效的节点
	var to_remove: Array = []
	for node_path in recorded_nodes.keys():
		var record_data = recorded_nodes[node_path]
		var node_ref: WeakRef = record_data["node_ref"]
		var node = node_ref.get_ref()
		
		if node == null or !is_instance_valid(node):
			to_remove.append(node_path)
	
	# 移除失效的记录
	for node_path in to_remove:
		var record_data = recorded_nodes[node_path]
		var item = record_data["item"]
		if is_instance_valid(item):
			item.queue_free()
		recorded_nodes.erase(node_path)
	
	# 如果有移除操作，更新 tip_label 的可见性
	if to_remove.size() > 0:
		_update_tip_label_visibility()
