@tool
extends VBoxContainer

@export
var expand_icon_tex: Texture2D
@export
var collapse_icon_tex: Texture2D
@export
var expand_btn: Button
@export
var attr_container: VBoxContainer

@export
var page_btn_root: HBoxContainer
@export
var next_btn: Button
@export
var prev_btn: Button
@export
var page_size: int = 20

@export
var delete_slot: PackedScene

var type: String = "array"

var _node  # 父对象（可能是Node，也可能是其他Object）
var _inspector_container
var _attr: String
var _value: Array  # 当前Array的值
var _array_wrapper: ArrayWrapper  # 数组包装器，用于支持set/get操作

var _is_expanded: bool = false
var _is_initialized: bool = false  # 是否已经初始化过元素

# 分页相关
var _current_page: int = 0  # 当前页码（从0开始）
var _total_pages: int = 0   # 总页数

# 数组包装器类，用于让数组支持字符串索引的get/set操作
class ArrayWrapper:
	var array: Array
	
	func _init(arr: Array):
		array = arr
	
	func get(index):
		var idx = int(index)
		if idx >= 0 and idx < array.size():
			return array[idx]
		return null
	
	func set(index, value):
		var idx = int(index)
		if idx >= 0 and idx < array.size():
			array[idx] = value

func _ready():
	expand_btn.pressed.connect(on_expand_btn_pressed)
	prev_btn.pressed.connect(_on_prev_page)
	next_btn.pressed.connect(_on_next_page)
	expand_btn.icon = collapse_icon_tex
	attr_container.visible = false
	page_btn_root.visible = false
	_update_button_state()
	pass

func on_expand_btn_pressed():
	_is_expanded = !_is_expanded
	if _is_expanded:
		_expand()
	else:
		_collapse()
	pass

# 展开Array
func _expand():
	expand_btn.icon = expand_icon_tex
	attr_container.visible = true
	# 第一次展开时才初始化元素
	if not _is_initialized:
		# 确保有ArrayWrapper
		if _array_wrapper == null and _value != null:
			_array_wrapper = ArrayWrapper.new(_value)
		_current_page = 0
		_initialize_elements()
		_is_initialized = true
		_update_page_buttons()

# 收起Array
func _collapse():
	_is_expanded = false
	expand_btn.icon = collapse_icon_tex
	attr_container.visible = false
	# 收起时销毁所有元素以节约性能
	_clear_elements()
	_is_initialized = false

func set_node(node, inspector_container = null):
	_node = node
	if inspector_container != null:
		_inspector_container = inspector_container
	pass

func set_attr_name(attr_name: String):
	_attr = attr_name
	pass

func set_value(value):
	# 如果Array变为null或空，且当前已经展开，则需要收起并销毁所有元素
	if (value == null or (value is Array and value.size() == 0)) and _is_expanded:
		_collapse()
	
	_value = value if value != null else []
	
	# 更新或创建ArrayWrapper
	if _array_wrapper == null:
		_array_wrapper = ArrayWrapper.new(_value)
	else:
		_array_wrapper.array = _value
	
	_update_button_state()
	
	# 如果已经展开且有值，更新所有元素
	if _is_expanded and _is_initialized and _value != null and _value.size() > 0:
		_update_elements()
	elif _is_expanded and _is_initialized:
		_update_page_buttons()
	pass

# 更新按钮状态和显示文本
func _update_button_state():
	if _value != null:
		var size = _value.size()
		expand_btn.text = "Array[%d]" % size
		expand_btn.disabled = size == 0
	else:
		expand_btn.text = "Array[null]"
		expand_btn.disabled = true
	pass

# 初始化数组元素（只显示当前页）
func _initialize_elements():
	if _value == null or _value.size() == 0:
		return
	
	_calculate_total_pages()
	
	var start_index = _current_page * page_size
	var end_index = min(start_index + page_size, _value.size())
	
	for i in range(start_index, end_index):
		_create_element_at_index(i)

# 创建指定索引的元素
func _create_element_at_index(index: int):
	if index < 0 or index >= _value.size():
		return
	
	var element_value = _value[index]
	
	# 需要preload AttrItem场景
	var attr_item_scene = preload("res://addons/ds_inspector/Attributes/AttrItem.tscn")
	
	# 创建AttrItem
	var attr_item = attr_item_scene.instantiate()
	
	# 创建DeleteSlot包裹AttrItem
	var delete_slot_instance = delete_slot.instantiate()
	delete_slot_instance.add_target_node(attr_item)
	
	# 连接删除按钮信号
	delete_slot_instance.delete_btn.pressed.connect(_on_delete_element.bind(index))
	
	# 找到PageBtnContainer的位置，在它之前插入
	var insert_index = -1
	for i in range(attr_container.get_child_count()):
		if attr_container.get_child(i) == page_btn_root:
			insert_index = i
			break
	
	if insert_index >= 0:
		attr_container.add_child(delete_slot_instance)
		attr_container.move_child(delete_slot_instance, insert_index)
	else:
		attr_container.add_child(delete_slot_instance)
	
	# 设置标签为索引
	attr_item.label.text = "[%d]" % index
	
	# 为数组元素创建一个虚拟的属性字典
	var prop = {
		"name": str(index),
		"hint": PROPERTY_HINT_NONE
	}
	
	# 设置节点和检查器容器
	attr_item.set_node(_node, _inspector_container)
	attr_item._check_value_change = false  # 数组元素不检查类型变化（会重新创建）
	attr_item._attr_name = str(index)
	attr_item._prop_hint = PROPERTY_HINT_NONE
	
	# 直接创建对应类型的attr
	var attr = attr_item._create_attr_for_value(element_value, prop)
	attr_item.add_child(attr)
	attr_item._attr = attr
	
	attr.set_node(_array_wrapper, _inspector_container)  # 传递数组包装器
	attr.set_attr_name(str(index))
	attr.set_value(element_value)
	
	# 更新类型信息
	attr_item._update_type_info(element_value)

# 更新所有元素的值（只更新当前页）
func _update_elements():
	if _value == null:
		return
	
	_calculate_total_pages()
	
	# 确保当前页码有效
	if _current_page >= _total_pages:
		_current_page = max(0, _total_pages - 1)
	
	var start_index = _current_page * page_size
	var end_index = min(start_index + page_size, _value.size())
	var page_element_count = end_index - start_index
	
	var children = attr_container.get_children()
	# 跳过PageBtnContainer，获取DeleteSlot节点
	var display_children = []
	for child in children:
		if child != page_btn_root and child.has_method("add_target_node"):
			display_children.append(child)
	
	var display_size = display_children.size()
	
	# 处理显示元素数量变化
	if page_element_count < display_size:
		# 元素变少，删除多余元素（从后往前删）
		for i in range(display_size - 1, page_element_count - 1, -1):
			if i < display_children.size():
				var delete_slot_node = display_children[i]
				attr_container.remove_child(delete_slot_node)
				delete_slot_node.queue_free()
		display_children.resize(page_element_count)
	
	# 更新现有元素的值和索引标签
	for i in range(min(page_element_count, display_size)):
		var array_index = start_index + i
		if i < display_children.size():
			var delete_slot_node = display_children[i]
			# 从DeleteSlot中获取AttrItem
			var attr_item: DsAttrItem = null
			for child in delete_slot_node.get_children():
				if child is DsAttrItem:
					attr_item = child
					break
			
			if attr_item != null:
				var element_value = _value[array_index]
				
				# 更新索引标签
				attr_item.label.text = "[%d]" % array_index
				attr_item._attr_name = str(array_index)
				
				# 更新删除按钮的连接（断开所有连接，然后重新连接）
				_disconnect_delete_button(delete_slot_node.delete_btn)
				delete_slot_node.delete_btn.pressed.connect(_on_delete_element.bind(array_index))
				
				# 更新attr的索引和引用的包装器
				if attr_item._attr != null:
					# 确保attr引用的是最新的数组包装器
					if attr_item._attr.has_method("set_node"):
						attr_item._attr._node = _array_wrapper
					attr_item._attr.set_attr_name(str(array_index))
				
				# 检测类型是否变化，如果变化则重新创建
				if attr_item._should_recreate_attr(element_value):
					# 移除旧的attr
					if attr_item._attr != null:
						attr_item._attr.queue_free()
						attr_item._attr = null
					
					# 创建新的attr
					var prop = {
						"name": str(array_index),
						"hint": PROPERTY_HINT_NONE
					}
					var attr = attr_item._create_attr_for_value(element_value, prop)
					attr_item.add_child(attr)
					attr_item._attr = attr
					
					attr.set_node(_array_wrapper, _inspector_container)
					attr.set_attr_name(str(array_index))
					attr.set_value(element_value)
					
					# 更新类型信息
					attr_item._update_type_info(element_value)
				else:
					# 只更新值
					attr_item._attr.set_value(element_value)
	
	# 需要添加新元素
	if page_element_count > display_size:
		for i in range(display_size, page_element_count):
			var array_index = start_index + i
			_create_element_at_index(array_index)
	
	_update_page_buttons()

# 清除所有元素
func _clear_elements():
	for child in attr_container.get_children():
		if child != page_btn_root:
			child.queue_free()

# 计算总页数
func _calculate_total_pages():
	if _value == null or _value.size() == 0:
		_total_pages = 0
	else:
		_total_pages = ceili(float(_value.size()) / float(page_size))

# 更新分页按钮状态
func _update_page_buttons():
	_calculate_total_pages()
	
	# 如果总数小于等于页面大小，隐藏分页按钮
	if _value == null or _value.size() <= page_size:
		page_btn_root.visible = false
		return
	
	page_btn_root.visible = true
	
	# 更新按钮文本
	prev_btn.text = "上一页 (%d/%d)" % [_current_page + 1, _total_pages]
	next_btn.text = "下一页 (%d/%d)" % [_current_page + 1, _total_pages]
	
	# 更新按钮启用状态
	prev_btn.disabled = _current_page <= 0
	next_btn.disabled = _current_page >= _total_pages - 1

# 上一页
func _on_prev_page():
	if _current_page > 0:
		_current_page -= 1
		_refresh_page()

# 下一页
func _on_next_page():
	if _current_page < _total_pages - 1:
		_current_page += 1
		_refresh_page()

# 刷新当前页显示
func _refresh_page():
	# 清除当前显示的元素
	for child in attr_container.get_children():
		if child != page_btn_root:
			attr_container.remove_child(child)
			child.queue_free()
	
	# 重新初始化当前页元素
	_initialize_elements()
	_update_page_buttons()

# 断开删除按钮的所有连接
func _disconnect_delete_button(btn: Button):
	var connections = btn.pressed.get_connections()
	for conn in connections:
		btn.pressed.disconnect(conn.callable)

# 删除指定索引的元素
func _on_delete_element(index: int):
	if _value == null or index < 0 or index >= _value.size():
		return
	
	# 从数组中移除元素
	_value.remove_at(index)
	
	# 更新按钮状态
	_update_button_state()
	
	# 如果数组为空，收起
	if _value.size() == 0:
		_collapse()
		return
	
	# 重新计算总页数
	_calculate_total_pages()
	
	# 如果删除后当前页没有元素了，跳转到上一页
	if _current_page >= _total_pages:
		_current_page = max(0, _total_pages - 1)
	
	# 刷新当前页显示
	_refresh_page()