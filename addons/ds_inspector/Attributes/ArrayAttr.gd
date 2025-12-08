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

var type: String = "array"

var _node  # 父对象（可能是Node，也可能是其他Object）
var _inspector_container
var _attr: String
var _value: Array  # 当前Array的值

var _is_expanded: bool = false
var _is_initialized: bool = false  # 是否已经初始化过元素

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
	
	# 需要preload AttrItem场景
	var attr_item_scene = preload("res://addons/ds_inspector/Attributes/AttrItem.tscn")
	
	for i in range(_value.size()):
		var element_value = _value[i]
		
		# 创建AttrItem
		var attr_item = attr_item_scene.instantiate()
		attr_container.add_child(attr_item)
		
		# 设置标签为索引
		attr_item.label.text = "[%d]" % i
		
		# 为数组元素创建一个虚拟的属性字典
		var prop = {
			"name": str(i),
			"hint": PROPERTY_HINT_NONE
		}
		
		# 设置节点和检查器容器
		attr_item.set_node(_node, _inspector_container)
		attr_item._check_value_change = false  # 数组元素不检查类型变化（会重新创建）
		attr_item._attr_name = str(i)
		attr_item._prop_hint = PROPERTY_HINT_NONE
		
		# 直接创建对应类型的attr
		var attr = attr_item._create_attr_for_value(element_value, prop)
		attr_item.add_child(attr)
		attr_item._attr = attr
		
		attr.set_node(_value, _inspector_container)  # 传递数组本身作为节点
		attr.set_attr_name(str(i))
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
	
	# 如果数组大小变化，重新初始化
	if current_size != display_size:
		_clear_elements()
		_initialize_elements()
		return
	
	# 更新现有元素的值
	for i in range(current_size):
		if i < children.size() and children[i] is DsAttrItem:
			var attr_item: DsAttrItem = children[i]
			var element_value = _value[i]
			
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
				
				attr.set_node(_value, _inspector_container)
				attr.set_attr_name(str(i))
				attr.set_value(element_value)
				
				# 更新类型信息
				attr_item._update_type_info(element_value)
			else:
				# 只更新值
				attr_item._attr.set_value(element_value)

# 清除所有元素
func _clear_elements():
	for child in attr_container.get_children():
		child.queue_free()