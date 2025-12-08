@tool
extends VBoxContainer

@export
var r_line_edit: LineEdit
@export
var g_line_edit: LineEdit
@export
var b_line_edit: LineEdit
@export
var a_line_edit: LineEdit
@export
var color_picker: ColorPickerButton

var type: String = "color"

var _attr: String
var _node: Node

var _focus_flag: bool = false
var _picker_open: bool = false  # 标记颜色选择器是否打开
var _temp_value: Color

func _ready():
	r_line_edit.text_changed.connect(_on_r_text_changed)
	g_line_edit.text_changed.connect(_on_g_text_changed)
	b_line_edit.text_changed.connect(_on_b_text_changed)
	a_line_edit.text_changed.connect(_on_a_text_changed)

	r_line_edit.focus_entered.connect(_on_focus_entered)
	g_line_edit.focus_entered.connect(_on_focus_entered)
	b_line_edit.focus_entered.connect(_on_focus_entered)
	a_line_edit.focus_entered.connect(_on_focus_entered)

	r_line_edit.focus_exited.connect(_on_focus_exited)
	g_line_edit.focus_exited.connect(_on_focus_exited)
	b_line_edit.focus_exited.connect(_on_focus_exited)
	a_line_edit.focus_exited.connect(_on_focus_exited)
	
	# 绑定 color_picker 的颜色变化事件
	color_picker.color_changed.connect(_on_color_picker_changed)
	# 监听颜色选择器的弹出窗口状态
	color_picker.popup_closed.connect(_on_picker_popup_closed)
	color_picker.pressed.connect(_on_picker_pressed)
	pass

func set_node(node: Node):
	_node = node

func set_attr_name(attr_name: String):
	_attr = attr_name

func set_value(value):
	if not value is Color:
		return
	# 如果输入框有焦点或颜色选择器打开，暂存值但不更新UI
	if _focus_flag or _picker_open:
		_temp_value = value
		return
	r_line_edit.text = str(value.r)
	g_line_edit.text = str(value.g)
	b_line_edit.text = str(value.b)
	a_line_edit.text = str(value.a)
	# 同步更新 color_picker
	color_picker.color = value

func _on_r_text_changed(new_str: String):
	_temp_value.r = float(new_str)
	# 同步更新 color_picker
	color_picker.color = _temp_value
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_g_text_changed(new_str: String):
	_temp_value.g= float(new_str)
	# 同步更新 color_picker
	color_picker.color = _temp_value
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_b_text_changed(new_str: String):
	_temp_value.b = float(new_str)
	# 同步更新 color_picker
	color_picker.color = _temp_value
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_a_text_changed(new_str: String):
	_temp_value.a = float(new_str)
	# 同步更新 color_picker
	color_picker.color = _temp_value
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)

func _on_color_picker_changed(color: Color):
	# 当 color_picker 改变时，更新输入框和节点属性
	_temp_value = color
	if not _focus_flag:
		r_line_edit.text = str(color.r)
		g_line_edit.text = str(color.g)
		b_line_edit.text = str(color.b)
		a_line_edit.text = str(color.a)
	if is_instance_valid(_node):
		_node.set(_attr, color)

func _on_focus_entered():
	_focus_flag = true
	pass

func _on_focus_exited():
	_focus_flag = false
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)
	pass

func _on_picker_pressed():
	# 当颜色选择器按钮被按下时，标记为打开状态
	_picker_open = true
	_temp_value = color_picker.color
	pass

func _on_picker_popup_closed():
	# 当颜色选择器弹出窗口关闭时，标记为关闭状态
	_picker_open = false
	if is_instance_valid(_node):
		_node.set(_attr, _temp_value)
	pass
