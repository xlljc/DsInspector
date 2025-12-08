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

var type: String = "array"

var _node  # 父对象（可能是Node，也可能是其他Object）
var _inspector_container
var _attr: String
var _value: Array  # 当前Array的值
var _array_wrapper: ArrayWrapper  # 数组包装器，用于支持set/get操作

var _is_expanded: bool = false
var _is_initialized: bool = false  # 是否已经初始化过元素

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
	expand_btn.icon = collapse_icon_tex
	attr_container.visible = false
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
		_initialize_elements()
		_is_initialized = true

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

# 初始化数组元素
func _initialize_elements():
	if _value == null or _value.size() == 0:
		return
	
	for i in range(_value.size()):
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
	attr_container.add_child(attr_item)
	
	# 如果需要插入到指定位置，调整顺序
	if index < attr_container.get_child_count() - 1:
		attr_container.move_child(attr_item, index)
	
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

# 更新所有元素的值
func _update_elements():
	if _value == null:
		return
	
	var children = attr_container.get_children()
	var current_size = _value.size()
	var display_size = children.size()
	
	# 处理数组大小变化
	if current_size < display_size:
		# 数组变小，删除多余元素（从后往前删）
		for i in range(display_size - 1, current_size - 1, -1):
			if i < children.size():
				var child = children[i]
				attr_container.remove_child(child)
				child.queue_free()
	
	# 更新现有元素的值和索引标签
	for i in range(min(current_size, display_size)):
		if i < children.size() and children[i] is DsAttrItem:
			var attr_item: DsAttrItem = children[i]
			var element_value = _value[i]
			
			# 更新索引标签
			attr_item.label.text = "[%d]" % i
			attr_item._attr_name = str(i)
			
			# 更新attr的索引和引用的包装器
			if attr_item._attr != null:
				# 确保attr引用的是最新的数组包装器
				if attr_item._attr.has_method("set_node"):
					attr_item._attr._node = _array_wrapper
				attr_item._attr.set_attr_name(str(i))
			
			# 检测类型是否变化，如果变化则重新创建
			if attr_item._should_recreate_attr(element_value):
				# 移除旧的attr
				if attr_item._attr != null:
					attr_item._attr.queue_free()
					attr_item._attr = null
				
				# 创建新的attr
				var prop = {
					"name": str(i),
					"hint": PROPERTY_HINT_NONE
				}
				var attr = attr_item._create_attr_for_value(element_value, prop)
				attr_item.add_child(attr)
				attr_item._attr = attr
				
				attr.set_node(_array_wrapper, _inspector_container)
				attr.set_attr_name(str(i))
				attr.set_value(element_value)
				
				# 更新类型信息
				attr_item._update_type_info(element_value)
			else:
				# 只更新值
				attr_item._attr.set_value(element_value)
	
	# 数组变大，添加新元素
	if current_size > display_size:
		for i in range(display_size, current_size):
			_create_element_at_index(i)

# 清除所有元素
func _clear_elements():
	for child in attr_container.get_children():
		child.queue_free()