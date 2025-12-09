@tool
extends Button

# 记录内容容器
@export
var record_root: VBoxContainer
@export
var scroll_container: ScrollContainer

# 外层分割容器
@export
var vsc: VSplitContainer

# 展开图标
@export
var expand_icon_tex: Texture2D
# 折叠图标
@export
var collapse_icon_tex: Texture2D

var is_expand: bool = false

func _ready():
	pressed.connect(_on_pressed)
	_set_expand_state(is_expand)

func _on_pressed():
	is_expand = !is_expand
	_set_expand_state(is_expand)

func _set_expand_state(is_expand: bool):
	if is_expand:
		icon = expand_icon_tex
		record_root.custom_minimum_size.y = 200
		vsc.split_offset = 200
		# 判断是否有 dragging_enabled 属性
		if vsc.has_method("set_dragging_enabled"):
			vsc.set_dragging_enabled(true)
		vsc.dragger_visibility = SplitContainer.DRAGGER_VISIBLE
		scroll_container.visible = true
	else:
		icon = collapse_icon_tex
		record_root.custom_minimum_size.y = 0
		vsc.split_offset = 0
		if vsc.has_method("set_dragging_enabled"):
			vsc.set_dragging_enabled(false)
		vsc.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
		scroll_container.visible = false
	pass