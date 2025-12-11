@tool
extends CenterContainer
class_name DsNodePathTips

@export
var use_font: Font

@export
var icon: TextureRect
@export
var label: Label
@export
var max_width: int = 800

func set_show_icon(texture: Texture):
	icon.texture = texture
	pass

func set_show_text(text: String, view_width: int):
	# 设置文本
	label.text = text
	
	# 计算icon宽度
	var icon_width: float = 0.0
	if icon != null:
		icon_width = icon.size.x
		if icon_width == 0:
			icon_width = icon.custom_minimum_size.x
	
	# 计算文本宽度（单行）
	var text_width: float = use_font.get_string_size(text).x
	
	# 计算总宽度（文本宽度 + icon宽度）
	var total_width: float = text_width + icon_width
	
	# 判断是否需要自动换行
	# 条件：屏幕宽度小于总宽度，或者总宽度超过最大宽度
	var need_wrap: bool = (view_width < total_width) or (total_width > max_width)
	
	if need_wrap:
		# 开启自动换行
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		# 计算可用宽度（减去icon宽度和可能的间距）
		var available_width: float = min(view_width, max_width) - icon_width
		if available_width > 0:
			# 设置label的宽度约束以触发换行
			# 使用custom_minimum_size来限制宽度，让布局系统自动处理
			label.custom_minimum_size.x = available_width
		else:
			# 如果可用宽度太小，至少设置一个最小值
			label.custom_minimum_size.x = 50
	else:
		# 关闭自动换行
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		# 重置宽度限制，让label根据内容自动调整
		label.custom_minimum_size.x = 0

func get_show_size() -> Vector2:
	# 计算icon尺寸
	var icon_width: float = 0.0
	var icon_height: float = 0.0
	if icon != null:
		icon_width = icon.size.x
		if icon_width == 0:
			icon_width = icon.custom_minimum_size.x
		icon_height = icon.size.y
		if icon_height == 0:
			icon_height = icon.custom_minimum_size.y
	
	# 获取label的实际尺寸
	var label_width: float = 0.0
	var label_height: float = 0.0
	
	# 优先使用实际渲染后的尺寸
	if label.size.x > 0:
		label_width = label.size.x
	if label.size.y > 0:
		label_height = label.size.y
	
	# 如果设置了custom_minimum_size，使用它
	if label_width == 0 and label.custom_minimum_size.x > 0:
		label_width = label.custom_minimum_size.x
	if label_height == 0 and label.custom_minimum_size.y > 0:
		label_height = label.custom_minimum_size.y
	
	# 否则计算文本尺寸
	if label.text.length() > 0:
		if label_width == 0:
			label_width = use_font.get_string_size(label.text).x
		if label_height == 0:
			# use_font 就是 label 使用的字体，直接使用 label 的字体大小
			var font_size = label.get_theme_font_size("font_size")
			label_height = use_font.get_height(font_size)
	
	# 返回总尺寸（宽度：icon宽度 + label宽度，高度：icon和label的最大值）
	return Vector2(icon_width + label_width, max(icon_height, label_height))