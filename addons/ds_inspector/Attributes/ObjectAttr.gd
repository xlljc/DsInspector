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

var type: String = "object"

var _node  # 父对象（可能是Node，也可能是其他Object）
var _inspector_container
var _attr: String
var _value  # 当前Object的值

var _is_expanded: bool = false
var _is_initialized: bool = false  # 是否已经初始化过子字段

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

# 展开Object
func _expand():
	expand_btn.icon = expand_icon_tex
	attr_container.visible = true
	# 第一次展开时才初始化子字段
	if not _is_initialized:
		_initialize_children()
		_is_initialized = true

# 收起Object
func _collapse():
	_is_expanded = false
	expand_btn.icon = collapse_icon_tex
	attr_container.visible = false
	# 收起时销毁所有子字段以节约性能
	_clear_children()
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
	# 如果Object变为null，且当前已经展开，则需要收起并销毁所有子属性
	if value == null and _is_expanded:
		_collapse()
	
	_value = value
	_update_button_state()
	
	# 如果已经展开且有值，更新所有子属性
	if _is_expanded and _is_initialized and value != null:
		_update_children()
	pass

# 更新按钮状态和显示文本
func _update_button_state():
	if _value != null:
		var obj_class_name = _value.get_class()
		expand_btn.text = "Object[%s]" % obj_class_name
		expand_btn.disabled = false
	else:
		expand_btn.text = "Object[null]"
		expand_btn.disabled = true
	pass

# 初始化子字段
func _initialize_children():
	if _value == null:
		return

	
	# 获取对象的所有属性
	var property_list = _value.get_property_list()
	
	# 需要preload AttrItem场景
	var attr_item_scene = _inspector_container.attr_item
	
	var has_properties = false
	for prop in property_list:
		# 过滤掉一些内部属性和不需要显示的属性
		if !_should_display_property(prop):
			continue
		
		has_properties = true
		
		# 创建AttrItem
		var attr_item = attr_item_scene.instantiate()
		attr_container.add_child(attr_item)
		
		# 设置节点和检查器容器（传递对象本身作为节点）
		attr_item.set_node(_value, _inspector_container)
		
		# 设置属性
		attr_item.set_attr(prop)
	
	# 如果没有可显示的属性，添加一个提示
	if not has_properties:
		var label = Label.new()
		label.text = "  (无可显示属性)"
		label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		attr_container.add_child(label)

# 更新所有子字段的值
func _update_children():
	if _value == null:
		return
	
	for child in attr_container.get_children():
		if child is DsAttrItem:
			var attr_item: DsAttrItem = child
			# 更新子AttrItem引用的对象（如果对象本身被替换了）
			attr_item._curr_node = _value
			# 获取对应属性的最新值
			var prop_value = _value.get(attr_item._attr_name)
			# 更新子属性的值
			attr_item.set_value(prop_value)

# 清除所有子字段
func _clear_children():
	for child in attr_container.get_children():
		child.queue_free()

func _should_display_property(prop: Dictionary) -> bool:
	# 过滤掉不需要显示的属性
	# 排除内部属性、RefCounted 相关属性等
	if prop.name in ["script", "Script Variables", "Resource", "RefCounted"]:
		return false
	
	# 只显示有用的属性标志
	var usage: int = prop.usage
	
	# 显示编辑器属性或脚本变量
	if usage & PROPERTY_USAGE_EDITOR or usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
		return true
	
	return false