@tool
extends HBoxContainer
class_name DsAttrItem

@export
var label: Label

var _curr_node  # 可以是Node或任何Object
var _inspector_container
var _attr

func set_node(node, inspector_container):
	_curr_node = node
	_inspector_container = inspector_container

func set_attr(prop: Dictionary):
	if _attr != null:
		printerr("AttrItem已经设置过属性了！")
		return

	label.text = prop.name
	var v = _curr_node.get(prop.name)

	# ------------- 特殊处理 -----------------
	if _curr_node is AnimatedSprite2D:
		if prop.name == "sprite_frames":
			_attr = _inspector_container.sprite_frames_attr.instantiate()
	# ---------------------------------------

	if _attr == null:
		if v == null:
			_attr = _inspector_container.rich_text_attr.instantiate()
		else:
			match typeof(v):
				TYPE_BOOL:
					_attr = _inspector_container.bool_attr.instantiate()
				TYPE_INT:
					if prop.hint == PROPERTY_HINT_ENUM:
						_attr = _inspector_container.enum_attr.instantiate()
					else:
						_attr = _inspector_container.int_attr.instantiate()
				TYPE_FLOAT:
					_attr = _inspector_container.float_attr.instantiate()
				TYPE_VECTOR2:
					_attr = _inspector_container.vector2_attr.instantiate()
				TYPE_VECTOR2I:
					_attr = _inspector_container.vector2I_attr.instantiate()
				TYPE_VECTOR3:
					_attr = _inspector_container.vector3_attr.instantiate() # 新增
				TYPE_VECTOR3I:
					_attr = _inspector_container.vector3I_attr.instantiate() # 新增
				TYPE_COLOR:
					_attr = _inspector_container.color_attr.instantiate()
				TYPE_RECT2:
					_attr = _inspector_container.rect_attr.instantiate()
				TYPE_RECT2I:
					_attr = _inspector_container.recti_attr.instantiate()
				TYPE_STRING:
					_attr = _inspector_container.string_attr.instantiate()
				TYPE_OBJECT:
					if v is Texture2D:
						_attr = _inspector_container.texture_attr.instantiate()
					else:
						# _attr = _inspector_container.rich_text_attr.instantiate()
						_attr = _inspector_container.object_attr.instantiate()
				_:
					_attr = _inspector_container.rich_text_attr.instantiate()
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
	_attr.set_value(value)
	pass
