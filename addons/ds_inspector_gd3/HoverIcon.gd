extends TextureButton

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var drag_move_flag: bool = false


const SAVE_PATH := "user://ds_inspector_icon.txt"

onready var debug_tool = get_node("/root/DsInspector")

func _ready():
	
	if OS.has_feature("standalone"): # 判断是否是导出模式
		get_parent().call_deferred("queue_free")
		pass
	_load_pos()
	connect("pressed", self, "_on_HoverIcon_pressed")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	pass

func _on_mouse_entered():
	if debug_tool:
		debug_tool._mouse_in_hover_btn = true
	pass

func _on_mouse_exited():
	if debug_tool:
		debug_tool._mouse_in_hover_btn = false
	pass

func _input(event):
	# 检测鼠标按下事件
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			drag_move_flag = false
			if get_global_rect().has_point(event.position):
				is_dragging = true
				drag_offset = event.position - rect_global_position
		else:
			is_dragging = false
			_save_pos()

	# 检测鼠标移动事件
	if event is InputEventMouseMotion and is_dragging:
		drag_move_flag = true
		rect_global_position = _clamp_to_screen(event.position - drag_offset)


func _on_HoverIcon_pressed():
	if !drag_move_flag:
		if debug_tool:
			debug_tool.show_panel()
	pass


func _save_pos():
	var file := File.new()
	if file.open(SAVE_PATH, File.WRITE) == OK:
		var pos := rect_global_position
		file.store_string(str(pos.x) + "," + str(pos.y))
		file.close()
	else:
		print("无法保存文件到 ", SAVE_PATH)
	pass

func _clamp_to_screen(pos: Vector2) -> Vector2:
	var vp := get_viewport().size
	var w := rect_size.x
	var h := rect_size.y
	# 确保在可视区域内
	pos.x = clamp(pos.x, 0, max(0, vp.x - w))
	pos.y = clamp(pos.y, 0, max(0, vp.y - h))
	return pos

func _load_pos():
	var file := File.new()
	if file.file_exists(SAVE_PATH):
		if file.open(SAVE_PATH, File.READ) == OK:
			var content := file.get_as_text()
			file.close()
			var parr := content.split(",")
			if parr.size() >= 2:
				var raw_pos := Vector2(float(parr[0]), float(parr[1]))
				var clamped := _clamp_to_screen(raw_pos)
				rect_global_position = clamped
				# 如果位置被修正，保存回配置文件以持久化
				if clamped != raw_pos:
					_save_pos()
	pass
