extends Node2D
class_name Brush


var node_tree
# 当前绘制的节点
var _draw_node: Node = null
var _in_canvaslayer: bool = false

onready var control: Control = $"../Control"
onready var icon_tex_rect: TextureRect = $"../Control/ColorRect/Icon"
onready var path_label: Label = $"../Control/Path"
onready var debug_tool = get_node("/root/DsInspector")

var _icon: Texture
var _show_text: bool = false

func _ready():
	control.visible = false
	pass

func _process(_delta):
	update()
	pass

func set_draw_node(node: Node) -> void:
	if node == null:
		_draw_node = null
		set_show_text(false)
		return
	_draw_node = node
	_in_canvaslayer = debug_tool.is_in_canvaslayer(node) if debug_tool else false
	var icon_path = node_tree.icon_mapping.get_icon(_draw_node.get_class())
	_icon = load(icon_path)
	icon_tex_rect.texture = _icon
	
	path_label.rect_size.x = 0
	control.rect_size.x = 0
	path_label.text = debug_tool.get_node_path(node) if debug_tool else ""
	pass

func set_show_text(flag: bool):
	_show_text = flag
	control.visible = flag
	pass

func _draw():
	if _draw_node != null:
		if !is_instance_valid(_draw_node):
			_draw_node = null
			return
		var op: Vector2 = Vector2.ZERO
		# c.rect_global_position
		if _draw_node is Control:
			op = _draw_node.rect_global_position
		elif _draw_node is Node2D:
			op = _draw_node.global_position
		else:
			op = op
		
		if !_in_canvaslayer:
			op = debug_tool.scene_to_ui(op) if debug_tool else op
		if _draw_node is CollisionShape2D:
			_draw_node_shape(op)
		elif _draw_node is CollisionPolygon2D:
			_draw_node_collision_polygon(op)
		elif _draw_node is Polygon2D:
			_draw_node_polygon(op)
		else:
			_draw_node_rect(op)

		if _show_text:
			var view_size: Vector2 = get_viewport().size
			var con_size: Vector2 = control.rect_size
			var pos: Vector2 = op
			# 限制在屏幕内
			if pos.x + con_size.x > view_size.x:
				pos.x = view_size.x - con_size.x
			elif pos.x < 0:
				pos.x = 0
			if pos.y + con_size.y > view_size.y:
				pos.y = view_size.y - con_size.y
			elif  pos.y < 0:
				pos.y = 0
			control.rect_position = pos
	pass

func _draw_node_shape(op):
	if _draw_node and _draw_node.shape:
		var camera_zoom = debug_tool.get_camera_zoom() if debug_tool else Vector2.ONE
		draw_set_transform(op, _draw_node.global_rotation, _draw_node.global_scale / camera_zoom)
		_draw_node.shape.draw(get_canvas_item(), Color(0, 1, 1, 0.5))
		draw_set_transform(Vector2.ZERO, 0, Vector2.ZERO)

	# 可视化中心点（可选）
	draw_circle(op, 3, Color(1, 0, 0))
	pass

func _draw_node_collision_polygon(op):
	if _draw_node and _draw_node.polygon.size() > 0:
		var points = _draw_node.polygon
		# 画轮廓线
		var arr = []
		arr.append_array(points)
		arr.append(points[0])
		var camera_zoom = debug_tool.get_camera_zoom() if debug_tool else Vector2.ONE
		draw_set_transform(op, _draw_node.global_rotation, _draw_node.global_scale / camera_zoom)
		# 画填充多边形
		draw_polygon(points, [Color(1, 0, 0, 0.3)])  # 半透明红色
		draw_polyline(arr, Color(1, 0, 0), 2.0)  # 闭合线
		draw_set_transform(Vector2.ZERO, 0, Vector2.ZERO)

	# 可视化中心点（可选）
	draw_circle(op, 3, Color(1, 0, 0))
	pass

func _draw_node_polygon(op):
	if _draw_node and _draw_node.polygon.size() > 0:
		var points = _draw_node.polygon
		# 画轮廓线
		var arr = []
		for i in range(points.size()):
			arr.append(points[i] + _draw_node.offset)
		arr.append(arr[0])
		var camera_zoom = debug_tool.get_camera_zoom() if debug_tool else Vector2.ONE
		draw_set_transform(op, _draw_node.global_rotation, _draw_node.global_scale / camera_zoom)
		# 画填充多边形
		draw_polygon(arr, [Color(1, 0, 0, 0.3)])  # 半透明红色
		draw_polyline(arr, Color(1, 0, 0), 2.0)  # 闭合线
		draw_set_transform(Vector2.ZERO, 0, Vector2.ZERO)

	# 可视化中心点（可选）
	draw_circle(op, 3, Color(1, 0, 0))
	pass

func _draw_node_rect(op):
	var camera_zoom: Vector2 = debug_tool.get_camera_zoom() if debug_tool else Vector2.ONE
	var rect = debug_tool.get_node_rect(_draw_node, camera_zoom , 1 if _in_canvaslayer else 0) if debug_tool else null
	if rect:
		var offset: Vector2 = op - rect.position
		_draw_rect_outline(op, rect.size, rect.rotation, offset, 2, Color.red)

func _draw_rect_outline(pos: Vector2, size: Vector2, rotation: float, offset: Vector2, line_width := 2, color := Color.white):
	var points = [
		- offset,
		- offset + Vector2(size.x, 0),
		- offset + Vector2(size.x, size.y),
		- offset + Vector2(0, size.y),
	]

	# 应用旋转和平移
	var final_points = []
	for p in points:
		final_points.append(pos + p.rotated(rotation))

	# 绘制边框线段
	for i in range(4):
		var a = final_points[i]
		var b = final_points[(i + 1) % 4]
		draw_line(a, b, color, line_width)
	
	# 可视化中心点（可选）
	draw_circle(pos, 3, Color(1, 0, 0))
