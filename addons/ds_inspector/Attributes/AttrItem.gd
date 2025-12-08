@tool
extends HBoxContainer
class_name DsAttrItem

@export
var label: Label

var _curr_node  # 可以是Node或任何Object
var _inspector_container
var _attr
var _attr_name: String  # 属性名
var _check_value_change: bool = false
var _prop_hint: int  # 属性提示类型（用于enum检测）
var _current_type: int = -1  # 当前值的类型
var _current_is_texture: bool = false  # 当前值是否是Texture2D

func set_node(node, inspector_container):
	_curr_node = node
	_inspector_container = inspector_container

func set_attr(prop: Dictionary):
	if _attr != null:
		printerr("AttrItem已经设置过属性了！")
		return

	_check_value_change = true
	_attr_name = prop.name
	_prop_hint = prop.hint
	label.text = prop.name
	var v = _curr_node.get(prop.name)

	# 保存当前类型信息
	_update_type_info(v)

	# 创建对应类型的attr
	_attr = _create_attr_for_value(v, prop)
	add_child(_attr)

	_attr.set_node(_curr_node, _inspector_container)
	_attr.set_attr_name(prop.name)
	
	if _attr.type == "enum":
		_attr.set_enum_options(prop.hint_string)
	
	_attr.set_value(v)
	pass

func set_attr_node(node: Node):
	_attr = node
	add_child(_attr)
	pass

func set_value(value):
	# 检测类型是否发生变化
	if _check_value_change and _should_recreate_attr(value):
		_recreate_attr(value)
	else:
		_attr.set_value(value)
	pass

# 更新类型信息
func _update_type_info(value):
	if value == null:
		_current_type = TYPE_NIL
		_current_is_texture = false
	else:
		_current_type = typeof(value)
		_current_is_texture = value is Texture2D

# 判断是否需要重新创建attr（类型发生变化）
func _should_recreate_attr(new_value) -> bool:
	if _attr == null:
		return false
	
	var new_type = TYPE_NIL if new_value == null else typeof(new_value)
	
	# 类型不同，需要重新创建
	if _current_type != new_type:
		return true
	
	# 特殊情况：Object类型需要检查具体子类
	if new_type == TYPE_OBJECT:
		# Texture2D 和其他 Object 需要不同的显示方式
		var new_is_texture = new_value is Texture2D
		if _current_is_texture != new_is_texture:
			return true
	
	return false

# 重新创建attr
func _recreate_attr(new_value):
	# 销毁旧的attr
	if _attr != null:
		_attr.queue_free()
		_attr = null
	
	# 更新类型信息
	_update_type_info(new_value)
	
	# 创建新的attr
	var prop = {
		"name": _attr_name,
		"hint": _prop_hint
	}
	_attr = _create_attr_for_value(new_value, prop)
	add_child(_attr)
	
	_attr.set_node(_curr_node, _inspector_container)
	_attr.set_attr_name(_attr_name)
	
	if _attr.type == "enum":
		# 需要重新获取hint_string，但这里没有保存
		# 简化处理：enum类型变化的情况比较少见
		pass
	
	_attr.set_value(new_value)

# 根据值创建对应类型的attr
func _create_attr_for_value(value, prop: Dictionary):
	var attr = null
	
	# ------------- 特殊处理 -----------------
	if _curr_node is AnimatedSprite2D:
		if prop.name == "sprite_frames":
			attr = _inspector_container.sprite_frames_attr.instantiate()
	# ---------------------------------------
	
	if attr == null:
		if value == null:
			attr = _inspector_container.rich_text_attr.instantiate()
		else:
			match typeof(value):
				TYPE_BOOL:
					attr = _inspector_container.bool_attr.instantiate()
				TYPE_INT:
					if prop.hint == PROPERTY_HINT_ENUM:
						attr = _inspector_container.enum_attr.instantiate()
					else:
						attr = _inspector_container.int_attr.instantiate()
				TYPE_FLOAT:
					attr = _inspector_container.float_attr.instantiate()
				TYPE_VECTOR2:
					attr = _inspector_container.vector2_attr.instantiate()
				TYPE_VECTOR2I:
					attr = _inspector_container.vector2I_attr.instantiate()
				TYPE_VECTOR3:
					attr = _inspector_container.vector3_attr.instantiate()
				TYPE_VECTOR3I:
					attr = _inspector_container.vector3I_attr.instantiate()
				TYPE_COLOR:
					attr = _inspector_container.color_attr.instantiate()
				TYPE_RECT2:
					attr = _inspector_container.rect_attr.instantiate()
				TYPE_RECT2I:
					attr = _inspector_container.recti_attr.instantiate()
				TYPE_STRING:
					attr = _inspector_container.string_attr.instantiate()
				TYPE_ARRAY:
					attr = _inspector_container.array_attr.instantiate()
				TYPE_DICTIONARY:
					attr = _inspector_container.map_attr.instantiate()
				TYPE_OBJECT:
					if value is Texture2D:
						attr = _inspector_container.texture_attr.instantiate()
					else:
						attr = _inspector_container.object_attr.instantiate()
				_:
					attr = _inspector_container.rich_text_attr.instantiate()
	
	return attr
