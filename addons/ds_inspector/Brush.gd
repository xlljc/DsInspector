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

var is_draw_in_window: bool = true

var _icon: Texture
var _show_text: bool = false

func _ready():
	node_path_tips.visible = false
	pass

func _process(_delta):
	if _has_draw_node and (_draw_node == null or !is_instance_valid(_draw_node) or !_draw_node.is_inside_tree()):
		_draw_node = null
		_has_draw_node = false
	queue_redraw()
	pass

func get_draw_node() -> Node:
	if !_has_draw_node:
		return null
	if !is_instance_valid(_draw_node):
		_draw_node = null
		_has_draw_node = false
		return null
	return _draw_node

func set_draw_node(node: Node) -> void:
	if node == null:
		_draw_node = null
		_has_draw_node = false
		set_show_text(false)
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

func _draw():
	if !_has_draw_node:
		return
	if _draw_node == null or !is_instance_valid(_draw_node):
		_draw_node = null
		_has_draw_node = false
		return

	var scale: Vector2

	var camera_trans: DsCameraTransInfo = debug_tool.get_camera_trans(debug_tool.curr_camera)
	var node_trans: DsNodeTransInfo = debug_tool.calc_node_rect(_draw_node)
	var pos: Vector2
	var rot: float

	var trans = get_node_trans(_draw_node)
	pos = trans.position
	scale = trans.scale
	rot = trans.rotation

	if _draw_node is CollisionShape2D:
		_draw_node_shape(_draw_node.shape, pos, scale, rot)
	elif _draw_node is CollisionPolygon2D or _draw_node is Polygon2D:
		_draw_node_polygon(_draw_node.polygon, pos, scale, rot)
	elif _draw_node is LightOccluder2D:
		if _draw_node.occluder != null:
			_draw_node_polygon(_draw_node.occluder.polygon, pos, scale, rot)
		else:
			_draw_node_rect(pos, scale, node_trans.size, rot, false)
	elif _draw_node is VisibleOnScreenEnabler2D or _draw_node is VisibleOnScreenNotifier2D:
		_draw_node_rect(pos, scale, node_trans.size, rot, true)
	else:
		_draw_node_rect(pos, scale, node_trans.size, rot, false)

	if _show_text:
		node_path_tips.visible = true
		var view_size: Vector2 = get_viewport().size
		var label_size: Vector2 = path_label.size
		var tips_size: Vector2 = node_path_tips.size
		var text_size: Vector2 = Vector2(max(label_size.x, tips_size.x), max(label_size.y, tips_size.y))
		var text_pos: Vector2 = pos + Vector2(-50, 50)
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

func get_node_trans(node: Node) -> DsViewportTransInfo:
	var curr_node: Node = node
	var root_viewport: Viewport = get_viewport()
	var result: DsViewportTransInfo = DsViewportTransInfo.new()
	
	while curr_node != null:

		var in_canvaslayer: bool = false
		var temp_curr: Node = curr_node
		var viewport: Viewport = null

		while temp_curr != null:
			if temp_curr is CanvasLayer:
				in_canvaslayer = true
			elif temp_curr is Viewport:
				viewport = temp_curr
				temp_curr = temp_curr.get_parent()
				break
			temp_curr = temp_curr.get_parent()
		
		if viewport != null:
			calc_node_trans(curr_node, viewport, in_canvaslayer, result)

		curr_node = temp_curr
	return result

func calc_node_trans(node: Node, viewport: Viewport, in_canvaslayer: bool, view_trans: DsViewportTransInfo) -> void:
	var camera: Camera2D = viewport.get_camera_2d()
	var camera_trans: DsCameraTransInfo = debug_tool.get_camera_trans(camera)
	var node_trans: DsNodeTransInfo = debug_tool.calc_node_rect(node)
	if in_canvaslayer:
		view_trans.position += node_trans.position
		view_trans.rotation += node_trans.rotation
	else:
		view_trans.position += debug_tool.scene_to_ui(node_trans.position, camera)
		view_trans.rotation += node_trans.rotation - camera_trans.rotation
		view_trans.scale *= camera_trans.zoom


func _draw_node_shape(shape: Shape2D, pos: Vector2, scale: Vector2, rot: float):
	draw_circle(pos, 3, Color(1, 0, 0))
	if shape != null:
		draw_set_transform(pos, rot, scale)
		shape.draw(get_canvas_item(), Color(0, 1, 1, 0.5))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ZERO)

func _draw_node_polygon(polygon: PackedVector2Array, pos: Vector2, scale: Vector2, rot: float):
	draw_circle(pos, 3, Color(1, 0, 0))
	if polygon != null and polygon.size() > 0:
		# 画轮廓线
		var arr: Array[Vector2] = []
		arr.append_array(polygon)
		arr.append(polygon[0])
		draw_set_transform(pos, rot, scale)
		# 画填充多边形
		draw_polygon(polygon, [Color(1, 0, 0, 0.3)])  # 半透明红色
		draw_polyline(arr, Color(1, 0, 0), 2.0)  # 闭合线
		draw_set_transform(Vector2.ZERO, 0, Vector2.ZERO)

func _draw_node_rect(pos: Vector2, scale: Vector2, size: Vector2, rot: float, filled: bool):
	draw_circle(pos, 3, Color(1, 0, 0))
	if size == Vector2.ZERO:
		return
	# 设置绘制变换
	draw_set_transform(pos, rot, scale)
	# 绘制矩形
	var rect = Rect2(Vector2.ZERO, size)
	if filled:
		draw_rect(rect, Color(1,0,0,0.3), true)
	draw_rect(rect, Color(1,0,0), false, 1 / scale.x * 2)
	# 重置变换
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
