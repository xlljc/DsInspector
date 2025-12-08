extends Button

# 记录内容容器
@export
var record_root: VBoxContainer

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

func _on_pressed():
	is_expand = !is_expand
	if is_expand:
		icon = expand_icon_tex
		record_root.custom_minimum_size.y = 200
		vsc.split_offset = 200
		vsc.dragger_visibility = SplitContainer.DRAGGER_VISIBLE
	else:
		icon = collapse_icon_tex
		record_root.custom_minimum_size.y = 0
		vsc.split_offset = 0
		vsc.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
