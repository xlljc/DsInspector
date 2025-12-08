@tool
extends BaseAttr

@export
var label: Label
@export
var vboxcontainer: VBoxContainer

var type: String = "object"

var _attr: String
var _node: Node
var _current_value: Object = null
var _attr_map: Dictionary = {} # key: 属性名, value: AttrItem

# 预加载所有属性场景
@onready
var line: PackedScene = preload("res://addons/ds_inspector/Attributes/Line.tscn")
@onready
var rich_text_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/RichTextAttr.tscn")
@onready
var bool_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/BoolAttr.tscn")
@onready
var float_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/FloatAttr.tscn")
@onready
var int_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/IntAttr.tscn")
@onready
var vector2_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector2Attr.tscn")
@onready
var vector2I_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector2IAttr.tscn")
@onready
var vector3_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector3Attr.tscn")
@onready
var vector3I_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/Vector3IAttr.tscn")
@onready
var color_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/ColorAttr.tscn")
@onready
var rect_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/RectAttr.tscn")
@onready
var recti_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/RectIAttr.tscn")
@onready
var string_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/StringAttr.tscn")
@onready
var texture_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/TextureAttr.tscn")
@onready
var sprite_frames_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/SpriteFramesAttr.tscn")
@onready
var enum_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/EnumAttr.tscn")
@onready
var object_attr: PackedScene = preload("res://addons/ds_inspector/Attributes/ObjectAttr.tscn")

class AttrItem:
	var attr: BaseAttr
	var name: String
	var usage: int
	var type: int
	func _init(_attr: BaseAttr, _name: String, _usage: int, _type: int):
		attr = _attr
		name = _name
		usage = _usage
		type = _type

func set_node(_node: Node):
	_node = _node

func set_title(name: String):
	_attr = name
	label.text = name

func set_value(_value):
	if _value == null:
		_clear_all_attrs()
		_current_value = null
		return
	
	# 如果不是 Object 类型，显示为文本
	if not _value is Object:
		_clear_all_attrs()
		_current_value = null
		var rich_attr: BaseAttr = rich_text_attr.instantiate()
		vboxcontainer.add_child(rich_attr)
		rich_attr.set_node(_node)
		rich_attr.set_title("值")
		rich_attr.set_value(str(_value))
		return
	
	# 检查对象是否有效
	if not is_instance_valid(_value):
		_clear_all_attrs()
		_current_value = null
		return
	
	# 如果是新对象或对象类型改变，重新创建所有属性
	if _current_value != _value or (_current_value != null and _current_value.get_class() != _value.get_class()):
		_clear_all_attrs()
		_current_value = _value
		_init_object_attrs(_value)
	else:
		# 对象相同，更新属性
		_update_object_attrs(_value)

func _init_object_attrs(obj: Object):
	var props: Array[Dictionary] = obj.get_property_list()
	
	for prop in props:
		# 只显示有意义的属性（排除内部属性和类信息等）
		if _should_display_property(prop):
			var attr_item = _create_attr_for_property(obj, prop)
			if attr_item != null:
				_attr_map[prop.name] = attr_item

func _update_object_attrs(obj: Object):
	if obj == null or not is_instance_valid(obj):
		_clear_all_attrs()
		return
	
	var props: Array[Dictionary] = obj.get_property_list()
	var current_props: Dictionary = {}
	
	# 收集当前对象的所有有效属性
	for prop in props:
		if _should_display_property(prop):
			current_props[prop.name] = prop
	
	# 检查是否有删除的属性
	var attrs_to_remove: Array = []
	for attr_name in _attr_map.keys():
		if not current_props.has(attr_name):
			attrs_to_remove.append(attr_name)
	
	# 移除已删除的属性
	for attr_name in attrs_to_remove:
		var attr_item: AttrItem = _attr_map[attr_name]
		if attr_item.attr != null:
			vboxcontainer.remove_child(attr_item.attr)
			attr_item.attr.queue_free()
		_attr_map.erase(attr_name)
	
	# 检查新增属性和更新现有属性
	for prop_name in current_props.keys():
		var prop: Dictionary = current_props[prop_name]
		if _attr_map.has(prop_name):
			# 更新现有属性的值
			var attr_item: AttrItem = _attr_map[prop_name]
			var new_value = obj.get(prop_name)
			attr_item.attr.set_value(new_value)
		else:
			# 新增属性
			var attr_item = _create_attr_for_property(obj, prop)
			if attr_item != null:
				_attr_map[prop_name] = attr_item

func _create_attr_for_property(obj: Object, prop: Dictionary) -> AttrItem:
	var prop_value = obj.get(prop.name)
	var attr: BaseAttr = null
	
	# 根据属性类型创建相应的属性节点
	if prop_value == null:
		attr = rich_text_attr.instantiate()
	else:
		match typeof(prop_value):
			TYPE_BOOL:
				attr = bool_attr.instantiate()
			TYPE_INT:
				if prop.hint == PROPERTY_HINT_ENUM:
					attr = enum_attr.instantiate()
				else:
					attr = int_attr.instantiate()
			TYPE_FLOAT:
				attr = float_attr.instantiate()
			TYPE_VECTOR2:
				attr = vector2_attr.instantiate()
			TYPE_VECTOR2I:
				attr = vector2I_attr.instantiate()
			TYPE_VECTOR3:
				attr = vector3_attr.instantiate()
			TYPE_VECTOR3I:
				attr = vector3I_attr.instantiate()
			TYPE_COLOR:
				attr = color_attr.instantiate()
			TYPE_RECT2:
				attr = rect_attr.instantiate()
			TYPE_RECT2I:
				attr = recti_attr.instantiate()
			TYPE_STRING:
				attr = string_attr.instantiate()
			TYPE_OBJECT:
				if prop_value is Texture2D:
					attr = texture_attr.instantiate()
				elif prop_value is SpriteFrames:
					attr = sprite_frames_attr.instantiate()
				else:
					# 嵌套对象，递归使用 ObjectAttr
					attr = object_attr.instantiate()
			_:
				attr = rich_text_attr.instantiate()
	
	if attr == null:
		return null
	
	vboxcontainer.add_child(attr)
	attr.set_node(_node)
	attr.set_title(prop.name)
	
	# 如果是枚举类型，设置枚举选项
	if attr.type == "enum" and prop.hint == PROPERTY_HINT_ENUM:
		attr.set_enum_options(prop.hint_string)
	
	attr.set_value(prop_value)
	
	return AttrItem.new(attr, prop.name, prop.usage, prop.type)

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

func _clear_all_attrs():
	for attr_item in _attr_map.values():
		if attr_item.attr != null:
			vboxcontainer.remove_child(attr_item.attr)
			attr_item.attr.queue_free()
	_attr_map.clear()
