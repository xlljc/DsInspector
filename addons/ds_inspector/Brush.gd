@tool
extends Node2D
class_name DsBrush


var node_tree
# 当前绘制的节点
var _draw_node: Node = null
var _has_draw_node: bool = false
var _in_canvaslayer: bool = false

@export
var node_path_tips: Control# = $"../Control"
@export
var icon_tex_rect: TextureRect# = $"../Control/ColorRect/Icon"
@export
var path_label: Label# = $"../Control/Path"
@export
var debug_tool_path: NodePath

@onready
var debug_tool = get_node(debug_tool_path)

var _is_draw_in_viewport: bool = true
var _viewport_brush_layer: CanvasLayer
var _viewport_brush: Node2D
var _viewport_node: Viewport

var _icon: Texture
var _show_text: bool = false

func _ready():
	node_path_tips.visible = false
	_viewport_brush = Node2D.new()
	_viewport_brush.draw.connect(_on_viewport_brush_draw)
	_viewport_brush.name = "ViewportBrush"
	_viewport_brush_layer = CanvasLayer.new()
	_viewport_brush_layer.name = "ViewportBrushLayer"
	_viewport_brush_layer.layer = 128
	_viewport_brush_layer.add_child(_viewport_brush)
	pass

func _process(_delta):
	if _has_draw_node and (_draw_node == null or !is_instance_valid(_draw_node) or !_draw_node.is_inside_tree()):
		set_draw_node(null)
	queue_redraw()
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
		return
	_draw_node = node
	_has_draw_node = true
	_in_canvaslayer = debug_tool.is_in_canvaslayer(node)
	
	# 递归检查 node 是否在 Viewport 下
	# _in_viewprt = debug_tool.is_under_inner_viewport(node)
	
	var icon_path = node_tree.icon_mapping.get_icon(_draw_node)
	_icon = load(icon_path)
	icon_tex_rect.texture = _icon
	
	path_label.size.x = 0
	node_path_tips.size.x = 0
	path_label.text = debug_tool.get_node_path(node)
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

	# 先找是不是在 viewport 中
	if _is_draw_in_viewport:
		var viewport_node = find_viewport_node(_draw_node)
		if viewport_node != null:
			if viewport_node != _viewport_node:
				if _viewport_node != null:
					_viewport_node.remove_child(_viewport_brush_layer)
					_viewport_node = null
				_viewport_node = viewport_node
				_viewport_node.add_child(_viewport_brush_layer)
			return
		else:
			if _viewport_node != null:
				_viewport_node.remove_child(_viewport_brush_layer)
				_viewport_node = null

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
		var view_size: Vector2 = brush_node.get_viewport().size
		var label_size: Vector2 = path_label.size
		var tips_size: Vector2 = node_path_tips.size
		var text_size: Vector2 = Vector2(max(label_size.x, tips_size.x), max(label_size.y, tips_size.y))
		var text_pos: Vector2 = trans.position + Vector2(-50, 50)
		# 限制在屏幕内，结合 path_label 的大小
		if text_pos.x + text_size.x > view_size.x:
			text_pos.x = view_size.x - text_size.x
		elif text_pos.x < 0:
			text_pos.x = 0
		if text_pos.y + text_size.y > view_size.y:
			text_pos.y = view_size.y - text_size.y
		elif text_pos.y < 0:
			text_pos.y = 0
		node_path_tips.position = text_pos
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
	var root_viewport: Viewport = get_viewport()
	while curr_node != null:
		if curr_node is Viewport and curr_node != root_viewport:
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
