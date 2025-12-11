@tool
extends Node2D
class_name DsBrush


var node_tree
# 当前绘制的节点
var _draw_node: Node = null
var _has_draw_node: bool = false
var _in_canvaslayer: bool = false

@export
var node_path_tips: DsNodePathTips# = $"../Control"

@export
var debug_tool: CanvasLayer

var _viewport_brush_layer: CanvasLayer
var _viewport_brush: Node2D

var _viewport_node: Viewport
var _label_origin_root: Node

var _has_prev_click: bool = false
var _prev_click_pos: Vector2 = Vector2.ZERO
var _prev_click_view_size: Vector2 = Vector2.ZERO

var _icon: Texture
var _show_text: bool = false

var _root_viewport: Viewport = null

func _ready():
	_label_origin_root = node_path_tips.get_parent()
	node_path_tips.visible = false
	_viewport_brush = Node2D.new()
	_viewport_brush.draw.connect(_on_viewport_brush_draw)
	_viewport_brush.name = "ViewportBrush"
	_viewport_brush_layer = CanvasLayer.new()
	_viewport_brush_layer.name = "ViewportBrushLayer"
	_viewport_brush_layer.layer = 128
	_viewport_brush_layer.add_child(_viewport_brush)
	_root_viewport = get_viewport()
	pass

func _process(_delta):
	if _has_draw_node and (_draw_node == null or !is_instance_valid(_draw_node) or !_draw_node.is_inside_tree()):
		set_draw_node(null)
	queue_redraw()
	if _viewport_brush != null:
		_viewport_brush.queue_redraw()
	pass

func get_draw_node() -> Node:
	if !_has_draw_node:
		return null
	if !is_instance_valid(_draw_node):
		set_draw_node(null)
		return null
	return _draw_node

func set_draw_node(node: Node) -> void:
	if node == null:
		_draw_node = null
		_has_draw_node = false
		set_show_text(false)
		if _viewport_node != null:
			_viewport_node.remove_child(_viewport_brush_layer)
			_viewport_node = null
		# 还原
		var lb_parent = node_path_tips.get_parent()
		if lb_parent != _label_origin_root:
			if lb_parent != null:
				lb_parent.remove_child(node_path_tips)
			_label_origin_root.add_child(node_path_tips)
		return
	_has_prev_click = false
	_draw_node = node
	_has_draw_node = true
	_in_canvaslayer = debug_tool.is_in_canvaslayer(node)
	
	var icon_path = node_tree.icon_mapping.get_icon(_draw_node)
	_icon = load(icon_path)
	node_path_tips.set_show_icon(_icon)
	# 往上找是否有window节点，如果有则获取窗口大小，否则获取屏幕大小
	var window: Window = null
	var curr_node: Node = node.get_parent()
	while curr_node != null:
		if curr_node is Window and curr_node != _root_viewport:
			window = curr_node
			break
		curr_node = curr_node.get_parent()
	if window != null:
		node_path_tips.set_show_text(debug_tool.get_node_path(node), window.size.x)
	else:
		node_path_tips.set_show_text(debug_tool.get_node_path(node), _root_viewport.size.x)
	pass

func set_show_text(flag: bool):
	_show_text = flag
	node_path_tips.visible = flag
	pass


func _on_viewport_brush_draw():
	# print("on_window_brush_draw")
	if !_has_draw_node:
		return
	if _draw_node == null or !is_instance_valid(_draw_node):
		set_draw_node(null)
		return

	_draw_border(_viewport_brush)
	pass

func _draw():
	if !_has_draw_node:
		return
	if _draw_node == null or !is_instance_valid(_draw_node):
		set_draw_node(null)
		return

	# 检查是否开启视口检查
	if debug_tool.save_config.get_check_viewport():
		# 先找是不是在 viewport 中
		var viewport_node = find_viewport_node(_draw_node)
		if viewport_node != null:
			if viewport_node != _viewport_node:
				if _viewport_node != null:
					_viewport_node.remove_child(_viewport_brush_layer)
					_viewport_node = null
				_viewport_node = viewport_node
				_viewport_node.add_child(_viewport_brush_layer)

				if viewport_node is Window:
					var lb_parent = node_path_tips.get_parent()
					if lb_parent != _viewport_brush_layer:
						if lb_parent != null:
							lb_parent.remove_child(node_path_tips)
						_viewport_brush_layer.add_child(node_path_tips)
						_has_prev_click = false
				else: # 还原
					var lb_parent = node_path_tips.get_parent()
					if lb_parent != null:
						lb_parent.remove_child(node_path_tips)
					_label_origin_root.add_child(node_path_tips)
					_has_prev_click = false

			return
		else:
			if _viewport_node != null:
				_viewport_node.remove_child(_viewport_brush_layer)
				_viewport_node = null
			# 还原
			var lb_parent = node_path_tips.get_parent()
			if lb_parent != _label_origin_root:
				if lb_parent != null:
					lb_parent.remove_child(node_path_tips)
				_label_origin_root.add_child(node_path_tips)
				_has_prev_click = false

	_draw_border(self)
	pass

func _draw_border(brush_node: CanvasItem):
	var trans = calc_node_trans(_draw_node)

	if _draw_node is CollisionShape2D:
		_draw_node_shape(brush_node, _draw_node.shape, trans.position, trans.scale, trans.rotation)
	elif _draw_node is CollisionPolygon2D or _draw_node is Polygon2D:
		_draw_node_polygon(brush_node, _draw_node.polygon, trans.position, trans.scale, trans.rotation)
	elif _draw_node is LightOccluder2D:
		if _draw_node.occluder != null:
			_draw_node_polygon(brush_node, _draw_node.occluder.polygon, trans.position, trans.scale, trans.rotation)
		else:
			_draw_node_rect(brush_node, trans.position, trans.scale, trans.size, trans.rotation, false)
	elif _draw_node is VisibleOnScreenEnabler2D or _draw_node is VisibleOnScreenNotifier2D:
		_draw_node_rect(brush_node, trans.position, trans.scale, trans.size, trans.rotation, true)
	else:
		_draw_node_rect(brush_node, trans.position, trans.scale, trans.size, trans.rotation, false)

	if _show_text:
		node_path_tips.visible = true
		# 获取 node_path_tips 的实际尺寸（包括 icon 和 label）
		var text_size: Vector2 = node_path_tips.get_show_size()
		var half_size: Vector2 = text_size / 2.0
		var center_pos: Vector2
		var view_size: Vector2
		var base_pos: Vector2
		
		if _viewport_node == null:
			base_pos = trans.position
			view_size = brush_node.get_viewport().size
		else:
			if !_has_prev_click:
				_has_prev_click = true
				if _viewport_node is Window:
					_prev_click_pos = _viewport_node.get_mouse_position()
					_prev_click_view_size = _viewport_node.size
				else:
					_prev_click_pos = get_global_mouse_position()
					_prev_click_view_size = get_viewport_rect().size
			base_pos = _prev_click_pos
			view_size = _prev_click_view_size
		
		# 计算垂直偏移，考虑提示框高度，避免遮挡鼠标点击区域
		# 基础偏移50像素，加上提示框的半高，确保提示框底部不会遮挡鼠标
		var vertical_offset: float = 50.0 + half_size.y
		
		# 如果提示框高度太大，可能会超出屏幕下方，尝试放在鼠标上方
		var bottom_edge: float = base_pos.y + vertical_offset + half_size.y
		if bottom_edge > view_size.y:
			# 放在鼠标上方
			vertical_offset = -(50.0 + half_size.y)
		
		center_pos = base_pos + Vector2(0, vertical_offset)
		
		# node_path_tips.position 现在是中心点位置，需要计算左上角位置来限制边界
		var top_left: Vector2 = center_pos - half_size
		
		# 限制左上角在屏幕内
		if top_left.x + text_size.x > view_size.x:
			top_left.x = view_size.x - text_size.x
		elif top_left.x < 0:
			top_left.x = 0
		if top_left.y + text_size.y > view_size.y:
			top_left.y = view_size.y - text_size.y
		elif top_left.y < 0:
			top_left.y = 0
		
		# 将限制后的左上角位置转换回中心点位置
		center_pos = top_left + half_size
		node_path_tips.position = center_pos
	pass

func calc_node_trans(node: Node) -> DsViewportTransInfo:
	var in_canvaslayer: bool = false
	var viewport: Viewport = null
	var curr_node: Node = node.get_parent()
	while curr_node != null:
		if curr_node is CanvasLayer:
			in_canvaslayer = true
		elif curr_node is Viewport:
			viewport = curr_node
			break
		curr_node = curr_node.get_parent()

	var camera: Camera2D = viewport.get_camera_2d()
	var node_trans: DsNodeTransInfo = debug_tool.calc_node_rect(node)
	var view_trans: DsViewportTransInfo = DsViewportTransInfo.new()
	if in_canvaslayer:
		view_trans.position = node_trans.position
		view_trans.rotation = node_trans.rotation
		view_trans.scale = Vector2.ONE
		view_trans.size = node_trans.size
	else:
		var camera_trans: DsCameraTransInfo = debug_tool.get_camera_trans(camera)
		view_trans.position = debug_tool.scene_to_ui(node_trans.position, camera)
		view_trans.rotation = node_trans.rotation - camera_trans.rotation
		view_trans.scale = camera_trans.zoom
		view_trans.size = node_trans.size
	return view_trans

# 查找 node 的父级 Viewport 节点，不包括 root_viewport
func find_viewport_node(node: Node) -> Viewport:
	var curr_node: Node = node.get_parent()
	while curr_node != null:
		if curr_node is Viewport and curr_node != _root_viewport:
			return curr_node
		curr_node = curr_node.get_parent()
	return null

func _draw_node_shape(brush_node: CanvasItem, shape: Shape2D, pos: Vector2, scale: Vector2, rot: float):
	brush_node.draw_circle(pos, 3, Color(1, 0, 0))
	if shape != null:
		brush_node.draw_set_transform(pos, rot, scale)
		shape.draw(brush_node.get_canvas_item(), Color(0, 1, 1, 0.5))
		brush_node.draw_set_transform(Vector2.ZERO, 0, Vector2.ZERO)

func _draw_node_polygon(brush_node: CanvasItem, polygon: PackedVector2Array, pos: Vector2, scale: Vector2, rot: float):
	brush_node.draw_circle(pos, 3, Color(1, 0, 0))
	if polygon != null and polygon.size() > 0:
		# 画轮廓线
		var arr: Array[Vector2] = []
		arr.append_array(polygon)
		arr.append(polygon[0])
		brush_node.draw_set_transform(pos, rot, scale)
		# 画填充多边形
		brush_node.draw_polygon(polygon, [Color(1, 0, 0, 0.3)])  # 半透明红色
		brush_node.draw_polyline(arr, Color(1, 0, 0), 2.0)  # 闭合线
		brush_node.draw_set_transform(Vector2.ZERO, 0, Vector2.ZERO)

func _draw_node_rect(brush_node: CanvasItem, pos: Vector2, scale: Vector2, size: Vector2, rot: float, filled: bool):
	brush_node.draw_circle(pos, 3, Color(1, 0, 0))
	if size == Vector2.ZERO:
		return
	# 设置绘制变换
	brush_node.draw_set_transform(pos, rot, scale)
	# 绘制矩形
	var rect = Rect2(Vector2.ZERO, size)
	if filled:
		brush_node.draw_rect(rect, Color(1,0,0,0.3), true)
	brush_node.draw_rect(rect, Color(1,0,0), false, 1 / scale.x * 2)
	# 重置变换
	brush_node.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
