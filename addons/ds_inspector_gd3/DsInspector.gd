extends CanvasLayer

export var window_path: NodePath;
export var brush_path: NodePath;
export var mask_path: NodePath;
export var inspector_path: NodePath;
export var tips_path: NodePath;
export var tips_anim_path: NodePath;
export var cheat_path: NodePath;

onready var window: WindowDialog = get_node(window_path)
onready var brush: Brush = get_node(brush_path)
onready var mask: Control = get_node(mask_path)
onready var inspector: InspectorContainer = get_node(inspector_path)
onready var tips: Label = get_node(tips_path)
onready var tips_anim: AnimationPlayer = get_node(tips_anim_path)
onready var cheat: VBoxContainer = get_node(cheat_path)

var main_camera: Camera2D = null
var prev_click: bool = false
var _check_camer_timer: float = 0.0

# 排除列表
var _exclude_list: Array = []
var _selected_list: Array = []
var _has_exclude_coll: bool = false
var _coll_list: Array = []
var _tips_finish_count: int = 0
var _prev_mouse_position: Vector2 = Vector2.ZERO
# 是否开启拣选Ui
var _is_open_check_ui: bool = false
var _mouse_in_hover_btn: bool = false

class NodeTransInfo:
	var position: Vector2
	var size: Vector2
	var rotation: float
	func _init(_position: Vector2, _size: Vector2, _rotation: float):
		position = _position
		size = _size
		rotation = _rotation
	pass

func _ready():
	brush.node_tree = window.tree
	tips_anim.connect("animation_finished", self, "on_tip_anim_finished")
	pass

## func _on_idle_frame() -> void:
func _process(delta: float) -> void:
	######################### 拣选Ui相关 
	if _is_open_check_ui:
		if main_camera == null or !is_instance_valid(main_camera):
			main_camera = null
		_check_camer_timer -= delta
		if _check_camer_timer <= 0:
			## print("重新开始检测Camer相机")
			_check_camer_timer = 1.0
			check_camera()

		if !_mouse_in_hover_btn and Input.is_mouse_button_pressed(BUTTON_LEFT):
			if !prev_click:
				prev_click = true
				# 在macOS上使用Command键，其他平台使用Ctrl键
				var modifier_key_pressed = false
				var p = OS.get_name()
				if p == "OSX":
					modifier_key_pressed = Input.is_key_pressed(KEY_META)  # Command键
				else:
					modifier_key_pressed = Input.is_key_pressed(KEY_CONTROL)  # Ctrl键
				
				if modifier_key_pressed: # 按下修饰键, 执行向前选择
					if _selected_list.size() > 0:
						var node: Node = _selected_list.pop_back()
						if node != null and is_instance_valid(node):
							brush.set_draw_node(node)
							brush.set_show_text(true)
							return
				else:
					var node = get_check_node();
					if node != null:
						# print("选中节点: ", node.get_path())
						if brush._draw_node != null and is_instance_valid(brush._draw_node):
							_selected_list.append(brush._draw_node)
						brush.set_draw_node(node)
						brush.set_show_text(true)
						return
					elif _selected_list.size() > 1: # and _tips_finish_count < 5: # 最多提示 5 次
						if p == "OSX":
							tips.text = "错过了选中的节点？\n按住Command在点击鼠标左键可以回溯选择的节点！"
						else:
							tips.text = "错过了选中的节点？\n按住Ctrl在点击鼠标左键可以回溯选择的节点！"
						tips_anim.play("show")
						
		else:
			prev_click = false
	##################################################

func show_panel():
	window.do_show()
	pass

func check_camera():
	find_current_camera()
	# if main_camera != null:
	#	print("找到 Camera2D 节点: ", main_camera.get_path())
	pass

## 获取鼠标点击选中的节点
func get_check_node() -> Node:
	var mousePos: Vector2 = brush.get_global_mouse_position()
	if _prev_mouse_position != mousePos:
		_prev_mouse_position = mousePos
		_has_exclude_coll = false
		_exclude_list.clear()  # 清空排除列表
		_selected_list.clear()
		_coll_list.clear()

	# 优先检测碰撞体
	if !_has_exclude_coll:
		var space_state: Physics2DDirectSpaceState = brush.get_world_2d().direct_space_state
		var pos: Vector2
		if main_camera:
			pos = main_camera.get_global_mouse_position()
		else:
			pos = mousePos
		_coll_list = space_state.intersect_point(pos, 32, [], 2147483647, true, true)
		_has_exclude_coll = _coll_list.size() > 0
	
	if _has_exclude_coll:
		while _coll_list.size() > 0:
			var item = _coll_list[0]
			_coll_list.remove(0)
			var collider = item["collider"]
			if collider and is_instance_valid(collider) and !(collider is TileMap):
				var collision_shape = _find_collision_shape(collider)
				var node_path: String = get_node_path(collision_shape)
				# print("选中碰撞体: ", node_path)
				if !_is_path_excluded(node_path):
					return collision_shape
	
	var camera_zoom: Vector2 = get_camera_zoom()
	var node: Node = _each_and_check(get_tree().root, "", mousePos, camera_zoom, false, _exclude_list);
	if node != null:
		_exclude_list.append(node)
	return node

func _find_collision_shape(node: Node):
	if node == null:
		return null
	for child in node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return child
	return null

# 检查节点路径是否被排除（包括子路径检查）
func _is_path_excluded(node_path: String) -> bool:
	# 首先检查完全匹配
	if window.exclude_list.has_excludeL_path(node_path):
		return true
	
	# 然后检查是否是任何排除路径的子路径
	for exclude_path in window.exclude_list._list:
		if node_path.begins_with(exclude_path + "/"):
			return true
	
	return false

func _each_and_check(node: Node, path: String, mouse_position: Vector2, camera_zoom: Vector2, in_canvaslayer: bool, exclude_list: Array) -> Node:
	if node == self or window.exclude_list.has_excludeL_path(path):
		return null

	if !in_canvaslayer and node is CanvasLayer:
		in_canvaslayer = true;

	if exclude_list.has(node) or (node is Control and !node.visible) or (node is CanvasItem and !node.visible) or (node is CanvasLayer and !node.visible):
		return null

	for i in range(node.get_child_count() - 1, -1, -1):  # 从最后一个子节点到第一个子节点
		var child = node.get_child(i)
		var new_path: String
		if path.length() > 0:
			new_path = path + "/" + child.name
		else:
			new_path = child.name
		var result: Node = _each_and_check(child, new_path, mouse_position, camera_zoom, in_canvaslayer, exclude_list)
		if result != null:
			return result

	var rect: NodeTransInfo = get_node_rect(node, camera_zoom, 1 if in_canvaslayer else 0)
	if rect.size == Vector2.ZERO:
		return null
	if rect.rotation == 0:
		if is_in_rect(mouse_position.x, mouse_position.y, rect.position.x, rect.position.y, rect.size.x, rect.size.y):
			# print("is_in_rotated_rect: rotation: ", rect.rotation)
			return node
	else:
		var op: Vector2 = Vector2.ZERO
		if node is Control:
			op = node.rect_global_position
		elif node is Node2D:
			op = node.global_position
		if !in_canvaslayer:
			op = scene_to_ui(op)
		var offset: Vector2 = op - rect.position
		# print(mouse_position, rect.position)
		if is_in_rotated_rect(mouse_position, Rect2(rect.position, rect.size), rect.rotation, offset):
			return node
	return null

## 旋转矩形检测
func is_in_rotated_rect(mouse_pos: Vector2, rect: Rect2, rotation: float, offset: Vector2) -> bool:
	# 计算旋转中心点（世界坐标）
	var pivot = rect.position + offset
	
	# 将 mouse_pos 转换到矩形局部坐标系（反向旋转）
	var local_pos = (mouse_pos - pivot).rotated(-rotation)
	
	# 处理负尺寸：计算实际位置和尺寸
	var actual_position = rect.position
	var actual_size = rect.size.abs()  # 取尺寸的绝对值
	
	# 根据原始尺寸符号调整位置偏移
	if rect.size.x < 0:
		actual_position.x += rect.size.x  # 负X时向右调整原点
	if rect.size.y < 0:
		actual_position.y += rect.size.y  # 负Y时向下调整原点
	
	# 将矩形位置转换到相对于 pivot 的局部坐标
	var local_rect_pos = actual_position - pivot
	
	# 构造正向尺寸的局部矩形
	var local_rect = Rect2(local_rect_pos, actual_size)
	
	# 在未旋转空间中进行包含检测
	return local_rect.has_point(local_pos)


## 判断点 (targetX, targetY) 是否在矩形区域 (x, y, w, h) 内
func is_in_rect(targetX: float, targetY: float, x: float, y: float, w: float, h: float) -> bool:
	return targetX >= x and targetX <= x + w and targetY >= y and targetY <= y + h

## in_canvaslayer: -1 自动判断是不是在 CanvasLayer 中, 1 是在 CanvasLayer 中, 0 是不在 CanvasLayer 中
func get_node_rect(node: Node, camera_zoom: Vector2, in_canvaslayer: int = -1) -> NodeTransInfo:
	var rect: NodeTransInfo = _calc_node_rect(node)
	if rect.size.x == 0 or rect.size.y == 0:
		return rect
	if in_canvaslayer == -1:
		if is_in_canvaslayer(node):
			in_canvaslayer = 1
	if in_canvaslayer != 1: # 不是在 CanvasLayer 中
		rect.position = scene_to_ui(rect.position)
		rect.size /= camera_zoom
	return rect

func is_in_canvaslayer(node: Node) -> bool:
	var parent: Node = node.get_parent()
	while parent != null:
		if parent is CanvasLayer:
			return true
		parent = parent.get_parent()
	return false

func _calc_node_rect(node: Node) -> NodeTransInfo:
	## 获取节点的矩形范围
	if node is Control:
		var rect = node.get_global_rect()
		var r = 0
		var s: Vector2 = Vector2.ONE
		var curr_node: Node = node
		while curr_node != null:
			if curr_node is Control:
				r += deg2rad(curr_node.rect_rotation)
				s *= curr_node.rect_scale
			elif curr_node is CanvasItem:
				r += curr_node.global_rotation
				s *= curr_node.global_scale
				break
			curr_node = curr_node.get_parent()
		
		rect.size *= s
		return NodeTransInfo.new(rect.position, rect.size, r)
	elif node is Node2D:
		if node is Sprite:
			var texture: Texture = node.texture;
			if texture:
				var scale: Vector2 = node.global_scale;
				var size: Vector2
				if node.region_enabled:
					size = node.region_rect.size * scale
				else:
					size = texture.get_size() * scale;
				if node.centered:
					return NodeTransInfo.new(node.global_position - size * 0.5 + node.offset * scale, size, node.global_rotation)
				else:
					return NodeTransInfo.new(node.global_position + node.offset * scale, size, node.global_rotation)
		elif node is AnimatedSprite:
			var sf: SpriteFrames = node.frames
			if sf:
				# spriteFrames.GetFrameTexture(AnimatedSprite.Animation, AnimatedSprite.Frame);
				var curr_texture: Texture = sf.get_frame(node.animation, node.frame)
				if curr_texture:
					var scale: Vector2 = node.global_scale;
					var size: Vector2 = curr_texture.get_size() * scale;
					if node.centered:
						return NodeTransInfo.new(node.global_position - size * 0.5 + node.offset * scale, size, node.global_rotation)
					else:
						return NodeTransInfo.new(node.global_position + node.offset * scale, size, node.global_rotation)
		elif node is Light2D:
			var texture: Texture = node.texture;
			if texture:
				var scale: Vector2 = node.global_scale;
				var size: Vector2 = texture.get_size() * scale;
				return NodeTransInfo.new(node.global_position - size * 0.5 + node.offset * scale, size, node.global_rotation)
		elif node is TileMap:
			var scale: Vector2 = node.global_scale;
			var rect: Rect2 = node.get_used_rect()
			var size: Vector2 = rect.size * scale * node.cell_size
			var pos: Vector2 = rect.position * scale * node.cell_size
			return NodeTransInfo.new(pos + node.global_position, size, node.global_rotation)
		elif node is BackBufferCopy or node is VisibilityNotifier2D:
			var scale: Vector2 = node.global_scale;
			var rect: Rect2 = node.rect
			return NodeTransInfo.new(node.global_position + rect.position, rect.size * scale, node.global_rotation)

		return NodeTransInfo.new(node.global_position, Vector2.ZERO, node.global_rotation)
	return NodeTransInfo.new(Vector2.ZERO, Vector2.ZERO, 0)

func scene_to_ui(scene_position: Vector2) -> Vector2:
	if main_camera == null or !is_instance_valid(main_camera):
		return scene_position

	var camera_offset = main_camera.get_camera_screen_center()
	# var camera_offset = main_camera.global_position
	var camera_zoom = main_camera.zoom
	var size = main_camera.get_viewport_rect().size;
	
	# 将场景坐标转换为屏幕坐标
	var ui_position = (scene_position - camera_offset) / camera_zoom + size / 2
	
	return ui_position

func get_camera_zoom() -> Vector2:
	if main_camera != null and is_instance_valid(main_camera):
		return main_camera.zoom
	return Vector2.ONE

## 遍历场景树, 在控制台打印出来
func _each_tree(node: Node) -> void:
	var count := node.get_child_count()
	for i in range(count):
		var child := node.get_child(i)
		print(child.name, " ", child.get_class(), " ", child.get_path())
		_each_tree(child)
	pass
	
func find_current_camera() -> Camera2D:
	var viewport = get_viewport()
	if not viewport:
		main_camera = null
		return null
	if main_camera != null and is_instance_valid(main_camera):
		if main_camera.current and main_camera.get_viewport() == viewport:
			return main_camera
	var camerasGroupName = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)
	for camera in cameras:
		if camera is Camera2D and camera.current: 
			main_camera = camera
			return camera
	main_camera = null
	return null

# 获取一个节点的路径
func get_node_path(node: Node) -> String:
	var s: String
	var current: Node = node
	while current != null:
		var p = current.get_parent()
		if p == null:
			break
		if s.length() > 0:
			s = current.name + "/" + s
		else:
			s = current.name
		current = p
	return s

func on_tip_anim_finished(_name: String):
	_tips_finish_count += 1

func add_cheat_button(title: String, target: Node, method: String):
	cheat.add_cheat_button(title, target, method)
	pass
