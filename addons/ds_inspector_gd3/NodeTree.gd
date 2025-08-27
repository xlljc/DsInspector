extends Tree
class_name NodeTree

class NodeData:
	var name: String
	var node: Node
	var visible_icon_index: int = -1
	var script_icon_index: int = -1
	var scene_icon_index: int = -1
	var visible: bool = false
	func _init(_node: Node):
		name = _node.name
		node = _node
		pass
class TreeItemData:
	var node_data: NodeData
	var tree_item: TreeItem
	func _init(_node_data: NodeData, _tree_item: TreeItem):
		node_data = _node_data
		tree_item = _tree_item
		pass
class IconMapping:
	var mapping: Dictionary = {
		"AcceptDialog": "res://addons/ds_inspector_gd3/node_icon/icon_accept_dialog.svg",
		"AnimatedSprite": "res://addons/ds_inspector_gd3/node_icon/icon_animated_sprite.svg",
		"AnimationPlayer": "res://addons/ds_inspector_gd3/node_icon/icon_animation_player.svg",
		"AnimationTree": "res://addons/ds_inspector_gd3/node_icon/icon_animation_tree.svg",
		"AnimationTreePlayer": "res://addons/ds_inspector_gd3/node_icon/icon_animation_tree_player.svg",
		"Area2D": "res://addons/ds_inspector_gd3/node_icon/icon_area_2d.svg",
		"AspectRatioContainer": "res://addons/ds_inspector_gd3/node_icon/icon_aspect_ratio_container.svg",
		"AudioStreamPlayer": "res://addons/ds_inspector_gd3/node_icon/icon_audio_stream_player.svg",
		"AudioStreamPlayer2D": "res://addons/ds_inspector_gd3/node_icon/icon_audio_stream_player_2_d.svg",
		"BackBufferCopy": "res://addons/ds_inspector_gd3/node_icon/icon_back_buffer_copy.svg",
		"Bone2D": "res://addons/ds_inspector_gd3/node_icon/icon_bone_2_d.svg",
		"Button": "res://addons/ds_inspector_gd3/node_icon/icon_button.svg",
		"CPUParticles2D": "res://addons/ds_inspector_gd3/node_icon/icon_c_p_u_particles_2_d.svg",
		"Camera2D": "res://addons/ds_inspector_gd3/node_icon/icon_camera_2d.svg",
		"CanvasLayer": "res://addons/ds_inspector_gd3/node_icon/icon_canvas_layer.svg",
		"CanvasModulate": "res://addons/ds_inspector_gd3/node_icon/icon_canvas_modulate.svg",
		"CenterContainer": "res://addons/ds_inspector_gd3/node_icon/icon_center_container.svg",
		"CheckBox": "res://addons/ds_inspector_gd3/node_icon/icon_check_box.svg",
		"CheckButton": "res://addons/ds_inspector_gd3/node_icon/icon_check_button.svg",
		"CollisionPolygon2D": "res://addons/ds_inspector_gd3/node_icon/icon_collision_polygon_2d.svg",
		"CollisionShape2D": "res://addons/ds_inspector_gd3/node_icon/icon_collision_shape_2d.svg",
		"ColorPicker": "res://addons/ds_inspector_gd3/node_icon/icon_color_picker.svg",
		"ColorPickerButton": "res://addons/ds_inspector_gd3/node_icon/icon_color_picker_button.svg",
		"ColorRect": "res://addons/ds_inspector_gd3/node_icon/icon_color_rect.svg",
		"ConfirmationDialog": "res://addons/ds_inspector_gd3/node_icon/icon_confirmation_dialog.svg",
		"Container": "res://addons/ds_inspector_gd3/node_icon/icon_container.svg",
		"Control": "res://addons/ds_inspector_gd3/node_icon/icon_control.svg",
		"DampedSpringJoint2D": "res://addons/ds_inspector_gd3/node_icon/icon_damped_spring_joint_2d.svg",
		"FileDialog": "res://addons/ds_inspector_gd3/node_icon/icon_file_dialog.svg",
		"GraphEdit": "res://addons/ds_inspector_gd3/node_icon/icon_graph_edit.svg",
		"GraphNode": "res://addons/ds_inspector_gd3/node_icon/icon_graph_node.svg",
		"GridContainer": "res://addons/ds_inspector_gd3/node_icon/icon_grid_container.svg",
		"GrooveJoint2D": "res://addons/ds_inspector_gd3/node_icon/icon_groove_joint_2d.svg",
		"HBoxContainer": "res://addons/ds_inspector_gd3/node_icon/icon_h_box_container.svg",
		"HFlowContainer": "res://addons/ds_inspector_gd3/node_icon/icon_h_flow_container.svg",
		"HScrollBar": "res://addons/ds_inspector_gd3/node_icon/icon_h_scroll_bar.svg",
		"HSeparator": "res://addons/ds_inspector_gd3/node_icon/icon_h_separator.svg",
		"HSlider": "res://addons/ds_inspector_gd3/node_icon/icon_h_slider.svg",
		"HSplitContainer": "res://addons/ds_inspector_gd3/node_icon/icon_h_split_container.svg",
		"HTTPRequest": "res://addons/ds_inspector_gd3/node_icon/icon_h_t_t_p_request.svg",
		"ItemList": "res://addons/ds_inspector_gd3/node_icon/icon_item_list.svg",
		"KinematicBody2D": "res://addons/ds_inspector_gd3/node_icon/icon_kinematic_body_2d.svg",
		"Label": "res://addons/ds_inspector_gd3/node_icon/icon_label.svg",
		"Light2D": "res://addons/ds_inspector_gd3/node_icon/icon_light_2d.svg",
		"LightOccluder2D": "res://addons/ds_inspector_gd3/node_icon/icon_light_occluder_2d.svg",
		"Line2D": "res://addons/ds_inspector_gd3/node_icon/icon_line_2d.svg",
		"LineEdit": "res://addons/ds_inspector_gd3/node_icon/icon_line_edit.svg",
		"LinkButton": "res://addons/ds_inspector_gd3/node_icon/icon_link_button.svg",
		"Listener2D": "res://addons/ds_inspector_gd3/node_icon/icon_listener_2d.svg",
		"MarginContainer": "res://addons/ds_inspector_gd3/node_icon/icon_margin_container.svg",
		"MenuButton": "res://addons/ds_inspector_gd3/node_icon/icon_menu_button.svg",
		"MeshInstance2D": "res://addons/ds_inspector_gd3/node_icon/icon_mesh_instance_2d.svg",
		"MultiMeshInstance2D": "res://addons/ds_inspector_gd3/node_icon/icon_multi_mesh_instance_2d.svg",
		"Navigation2D": "res://addons/ds_inspector_gd3/node_icon/icon_navigation_2d.svg",
		"NavigationAgent": "res://addons/ds_inspector_gd3/node_icon/icon_navigation_agent.svg",
		"NavigationAgent2D": "res://addons/ds_inspector_gd3/node_icon/icon_navigation_agent_2d.svg",
		"NavigationObstacle": "res://addons/ds_inspector_gd3/node_icon/icon_navigation_obstacle.svg",
		"NavigationObstacle2D": "res://addons/ds_inspector_gd3/node_icon/icon_navigation_obstacle_2d.svg",
		"NavigationPolygonInstance": "res://addons/ds_inspector_gd3/node_icon/icon_navigation_polygon_instance.svg",
		"NinePatchRect": "res://addons/ds_inspector_gd3/node_icon/icon_nine_patch_rect.svg",
		"Node2D": "res://addons/ds_inspector_gd3/node_icon/icon_node_2d.svg",
		"OptionButton": "res://addons/ds_inspector_gd3/node_icon/icon_option_button.svg",
		"Panel": "res://addons/ds_inspector_gd3/node_icon/icon_panel.svg",
		"PanelContainer": "res://addons/ds_inspector_gd3/node_icon/icon_panel_container.svg",
		"ParallaxBackground": "res://addons/ds_inspector_gd3/node_icon/icon_parallax_background.svg",
		"ParallaxLayer": "res://addons/ds_inspector_gd3/node_icon/icon_parallax_layer.svg",
		"Particles2D": "res://addons/ds_inspector_gd3/node_icon/icon_particles_2d.svg",
		"Path2D": "res://addons/ds_inspector_gd3/node_icon/icon_path_2d.svg",
		"PathFollow2D": "res://addons/ds_inspector_gd3/node_icon/icon_path_follow_2d.svg",
		"PinJoint2D": "res://addons/ds_inspector_gd3/node_icon/icon_pin_joint_2d.svg",
		"Polygon2D": "res://addons/ds_inspector_gd3/node_icon/icon_polygon_2_d.svg",
		"Popup": "res://addons/ds_inspector_gd3/node_icon/icon_popup.svg",
		"PopupDialog": "res://addons/ds_inspector_gd3/node_icon/icon_popup_dialog.svg",
		"PopupMenu": "res://addons/ds_inspector_gd3/node_icon/icon_popup_menu.svg",
		"PopupPanel": "res://addons/ds_inspector_gd3/node_icon/icon_popup_panel.svg",
		"Position2D": "res://addons/ds_inspector_gd3/node_icon/icon_position_2d.svg",
		"ProgressBar": "res://addons/ds_inspector_gd3/node_icon/icon_progress_bar.svg",
		"RayCast2D": "res://addons/ds_inspector_gd3/node_icon/icon_ray_cast_2d.svg",
		"ReferenceRect": "res://addons/ds_inspector_gd3/node_icon/icon_reference_rect.svg",
		"RemoteTransform2D": "res://addons/ds_inspector_gd3/node_icon/icon_remote_transform_2d.svg",
		"ResourcePreloader": "res://addons/ds_inspector_gd3/node_icon/icon_resource_preloader.svg",
		"RichTextLabel": "res://addons/ds_inspector_gd3/node_icon/icon_rich_text_label.svg",
		"RigidBody2D": "res://addons/ds_inspector_gd3/node_icon/icon_rigid_body_2d.svg",
		"ScrollContainer": "res://addons/ds_inspector_gd3/node_icon/icon_scroll_container.svg",
		"ShapeCast2D": "res://addons/ds_inspector_gd3/node_icon/icon_shape_cast_2d.svg",
		"Skeleton2D": "res://addons/ds_inspector_gd3/node_icon/icon_skeleton_2d.svg",
		"SkeletonIK": "res://addons/ds_inspector_gd3/node_icon/icon_skeleton_i_k.svg",
		"Spatial": "res://addons/ds_inspector_gd3/node_icon/icon_spatial.svg",
		"SpinBox": "res://addons/ds_inspector_gd3/node_icon/icon_spin_box.svg",
		"Sprite": "res://addons/ds_inspector_gd3/node_icon/icon_sprite.svg",
		"StaticBody2D": "res://addons/ds_inspector_gd3/node_icon/icon_static_body_2d.svg",
		"TabContainer": "res://addons/ds_inspector_gd3/node_icon/icon_tab_container.svg",
		"Tabs": "res://addons/ds_inspector_gd3/node_icon/icon_tabs.svg",
		"TextEdit": "res://addons/ds_inspector_gd3/node_icon/icon_text_edit.svg",
		"TextureButton": "res://addons/ds_inspector_gd3/node_icon/icon_texture_button.svg",
		"TextureProgress": "res://addons/ds_inspector_gd3/node_icon/icon_texture_progress.svg",
		"TextureRect": "res://addons/ds_inspector_gd3/node_icon/icon_texture_rect.svg",
		"TileMap": "res://addons/ds_inspector_gd3/node_icon/icon_tile_map.svg",
		"Timer": "res://addons/ds_inspector_gd3/node_icon/icon_timer.svg",
		"ToolButton": "res://addons/ds_inspector_gd3/node_icon/icon_tool_button.svg",
		"TouchScreenButton": "res://addons/ds_inspector_gd3/node_icon/icon_touch_screen_button.svg",
		"Tree": "res://addons/ds_inspector_gd3/node_icon/icon_tree.svg",
		"Tween": "res://addons/ds_inspector_gd3/node_icon/icon_tween.svg",
		"VBoxContainer": "res://addons/ds_inspector_gd3/node_icon/icon_v_box_container.svg",
		"VFlowContainer": "res://addons/ds_inspector_gd3/node_icon/icon_v_flow_container.svg",
		"VScrollBar": "res://addons/ds_inspector_gd3/node_icon/icon_v_scroll_bar.svg",
		"VSeparator": "res://addons/ds_inspector_gd3/node_icon/icon_v_separator.svg",
		"VSlider": "res://addons/ds_inspector_gd3/node_icon/icon_v_slider.svg",
		"VSplitContainer": "res://addons/ds_inspector_gd3/node_icon/icon_v_split_container.svg",
		"VideoPlayer": "res://addons/ds_inspector_gd3/node_icon/icon_video_player.svg",
		"Viewport": "res://addons/ds_inspector_gd3/node_icon/icon_viewport.svg",
		"ViewportContainer": "res://addons/ds_inspector_gd3/node_icon/icon_viewport_container.svg",
		"VisibilityEnabler2D": "res://addons/ds_inspector_gd3/node_icon/icon_visibility_enabler_2d.svg",
		"VisibilityNotifier2D": "res://addons/ds_inspector_gd3/node_icon/icon_visibility_notifier_2d.svg",
		"WindowDialog": "res://addons/ds_inspector_gd3/node_icon/icon_window_dialog.svg",
		"WorldEnvironment": "res://addons/ds_inspector_gd3/node_icon/icon_world_environment.svg",
		"YSort": "res://addons/ds_inspector_gd3/node_icon/icon_y_sort.svg",
		"Node": "res://addons/ds_inspector_gd3/node_icon/icon_node.svg",
	}
	func get_icon(cls_name: String) -> String:
		if mapping.has(cls_name):
			return mapping[cls_name]
#		print("未知节点：", cls_name)
		return "res://addons/ds_inspector_gd3/node_icon/icon_error_sign.svg";
		pass
pass

export var update_time: float = 1  # 更新间隔时间
var _timer: float = 0.0  # 计时器
var _is_show: bool = false
var _init_tree: bool = false  # 是否已初始化树

var _is_in_select_func: bool = false
var _next_frame_index: int = 0
var _next_frame_select: TreeItem = null # 下一帧要选中的item
onready var icon_mapping: IconMapping = IconMapping.new()
onready var debug_tool = get_node("/root/DsInspector")
onready var _script_icon: Texture = preload("res://addons/ds_inspector_gd3/node_icon/icon_script.svg")
onready var _scene_icon: Texture = preload("res://addons/ds_inspector_gd3/node_icon/icon_play_scene.svg")
onready var _visible_icon: Texture = preload("res://addons/ds_inspector_gd3/Visible.png")
onready var _hide_icon: Texture = preload("res://addons/ds_inspector_gd3/Hide.png")

func _ready():
	# 选中item信号
	connect("item_selected", self, "_on_item_selected")
	# item按钮按下信号
	connect("button_pressed", self, "_on_button_pressed")
	# 展开收起节点信号
	connect("item_collapsed", self, "_on_item_collapsed")

func _process(delta):
	if _is_show:
		_timer += delta
		if _timer >= update_time:
			_timer = 0.0
			update_tree()  # 更新树
	if _next_frame_select != null:
		_next_frame_index -= 1
		if _next_frame_index <= 0:
			_next_frame_select.select(0)
			_next_frame_select = null
	pass

# 初始化树
func init_tree():
	_is_show = true

	# 获取场景树的根节点
	var root: Node = get_tree().root

	# 添加根节点到 Tree
	var root_item: TreeItem = create_item()
	root_item.set_text(0, root.name)
	var root_data: NodeData = NodeData.new(root)
	root_item.set_metadata(0, root_data)  # 存储节点引用
	if root is CanvasItem or root is Control:
		root_item.add_button(0, get_visible_icon(root_data.visible))  # 添加显示/隐藏按钮
	
	# 递归添加子节点
	for child in root.get_children():
		if debug_tool and child == debug_tool:
			continue  # 跳过 DsInspector 节点
		create_node_item(child, root_item)

# 显示场景树
func show_tree(select_node: Node = null):
	_is_show = true
	if !_init_tree:
		init_tree()
		_init_tree = true
	else:
		update_tree()  # 如果已经初始化，直接更新树
	
	# 定位选中的节点
	if select_node != null and is_instance_valid(select_node):
		call_deferred("locate_selected", select_node)
	else:
		if debug_tool:
			debug_tool.inspector.set_view_node(null)
	pass

# 隐藏场景树
func hide_tree():
	_is_show = false
	pass

# 更新场景树
func update_tree():
	var item: TreeItem = get_root()
	var data: NodeData = item.get_metadata(0)
	if data:
		var root_node: Node = get_tree().root
		if root_node != data.node:
			clear()
			init_tree()
			return
		# 算差异，分出新增、删除、修改的节点
		_update_children(item, data)
		return

	clear()
	init_tree()
	pass

# 删除选中的节点
func delete_selected():
	var item: TreeItem = get_selected()
	if item:
		var data: NodeData = item.get_metadata(0)
		if data:
			var parent: TreeItem = item.get_parent()
			data.node.queue_free()
			item.free()

			# 刷新场景树
			_update_children(parent, parent.get_metadata(0))
			return
	pass

# 定位选中的节点
func locate_selected(select_node: Node):
	if select_node == null or !is_instance_valid(select_node):
		if debug_tool:
			debug_tool.inspector.set_view_node(null)
		return
	# print("执行选中节点...")
	var path_arr: Array = []
	# 一路往上找父节点
	var current = select_node
	while current:
		path_arr.push_front(current)
		current = current.get_parent()
	
	_is_in_select_func = true
	# 再展开节点
	var curr_item: TreeItem = null
	var count: int = path_arr.size()
	for i in range(count):
		var node: Node = path_arr[i]
		if curr_item == null:
			curr_item = get_root()
		else: # 一路往下寻找
			var child_item: TreeItem = curr_item.get_children()
			var flag: bool = false
			while child_item:
				var node_data: NodeData = child_item.get_metadata(0)
				if !node_data: # 没有数据，错误
					_is_in_select_func = false
					return
				if node_data.node == node:
					flag = true
					if i < count: # 展开节点
						child_item.collapsed = false
					curr_item = child_item
					break
				child_item = child_item.get_next()
			
			if !flag: # 找不到，就创建
				curr_item = create_node_item(node, curr_item, false)
				break
	
	if curr_item == null:
		_is_in_select_func = false
		return
	var node_data: NodeData = curr_item.get_metadata(0)
	if !node_data:
		print("选择错问题，metadata 为 null！")
	
	_next_frame_index = 1
	_next_frame_select = curr_item;

	_is_in_select_func = false
	pass

# 更新子节点
func _update_children(parent_item: TreeItem, parent_data: NodeData):
	# 没展开就不要更新了
	if parent_item.collapsed:
		return

	var existing_node: Dictionary = {}
	var current: TreeItem = parent_item.get_children()
	while current:
		var node_data: NodeData = current.get_metadata(0)
		if node_data:
			existing_node[node_data.node] = TreeItemData.new(node_data, current)  # 存储现有节点
		current = current.get_next()

	# 遍历场景树的子节点
	for child_node in parent_data.node.get_children():
		if debug_tool and child_node == debug_tool:
			continue
		
		var child_data: TreeItemData = existing_node.get(child_node, null)
		if child_data:
			# 节点存在，更新显示名称和图标
			child_data.tree_item.set_text(0, child_node.name)
			if child_data.node_data.visible_icon_index >= 0:
				child_data.node_data.visible = child_data.node_data.node.visible
				child_data.tree_item.set_button(0, child_data.node_data.visible_icon_index, get_visible_icon(child_data.node_data.visible))  # 更新按钮图标

			# 从 existing_node 中移除已处理的节点
			existing_node.erase(child_node)
			# 递归更新子节点
			_update_children(child_data.tree_item, child_data.node_data)
			continue
		else:
			# 节点不存在，添加到 TreeItem
			create_node_item(child_node, parent_item)
	# 最后剩下的就是已删除的节点
	for item in existing_node.values():
		item.tree_item.free()  # 删除 TreeItem
	pass


# 创建一个新的 TreeItem
func create_node_item(node: Node, parent: TreeItem, add_slot: bool = true) -> TreeItem:
	var item: TreeItem = create_item(parent)
	item.collapsed = true
	var node_data = NodeData.new(node)
	item.set_metadata(0, node_data)  # 存储节点引用
	item.set_text(0, node.name)
	# item.set_icon(0, get_icon("Node", "EditorIcons"))
	item.set_icon(0, load(icon_mapping.get_icon(node.get_class())))

	var btn_index: int = 0
	if node.filename != "":
		node_data.scene_icon_index = btn_index
		item.add_button(0, _scene_icon)  # 添场景按钮
		btn_index += 1
	if node.get_script() != null:
		node_data.script_icon_index = btn_index
		item.add_button(0, _script_icon)  # 添加脚本按钮
		btn_index += 1
	if node is CanvasItem or node is Control or node is CanvasLayer:
		node_data.visible_icon_index = btn_index
		node_data.visible = node.visible
		item.add_button(0, get_visible_icon(node_data.visible))  # 添加显示/隐藏按钮
		btn_index += 1
	if add_slot and node.get_child_count() > 0:
		create_item(item)  # 创建一个子节点项以便展开
	return item

## 选中节点
func _on_item_selected():
	# 获取选中的 TreeItem
	var selected_item: TreeItem = get_selected()
	if selected_item:
		# 获取存储的节点引用
		var data: NodeData = selected_item.get_metadata(0)
		if data and debug_tool:
			debug_tool.brush.set_draw_node(data.node)
			debug_tool.inspector.set_view_node(data.node)

## 点击按钮节点
func _on_button_pressed(_item: TreeItem, _column: int, _id: int):
	if !_item:
		return
	# 获取按钮对应的节点
	var data: NodeData = _item.get_metadata(0)
	if data and is_instance_valid(data.node):
		if _id == data.visible_icon_index: # 按下显示/隐藏
			if data.node is CanvasItem or data.node is Control or data.node is CanvasLayer:
				# 切换节点的可见性
				data.visible = !data.node.visible  # 更新可见性状态
				data.node.visible = data.visible
				_item.set_button(0, _id, get_visible_icon(data.visible))  # 更新按钮图标
		elif _id == data.script_icon_index: # 按下脚本图标
			# # 执行 cmd 使用文件管理器打开脚本文件
			# var node_path: String = data.node.get_script().get_path() # 这里返回的路径为  res://path/to/file.gd
			# # 需要先转换路径为资源路径 res://path/to/file.gd -> path/to/file.gd
			var script: Script = data.node.get_script()
			if script:
				var res_path: String = script.get_path()  # 得到 res://path/to/file.gd
				_open_file(res_path)
		elif _id == data.scene_icon_index: # 按下场景按钮
			_open_file(data.node.filename)
			pass
			
func _open_file(res_path: String):
	var project_root: String = ProjectSettings.globalize_path("res://")
	var file_path: String = res_path.replace("res://", project_root).replace("/", "\\")
	if OS.get_name() == "Windows":
		OS.execute("cmd.exe", ["/c", "explorer.exe /select,\"" + file_path + "\""], false)
	elif OS.get_name() == "OSX":
		# 打开指定文件夹
		var mac_path = res_path.replace("res://", project_root)
		# Finder 选中文件
		OS.execute("open", ["-R", mac_path], false)

## 展开收起物体
func _on_item_collapsed(item: TreeItem):
	if item.collapsed:
		return
	var children: TreeItem = item.get_children()
	if !children: # 没有子节点
		var data: NodeData = item.get_metadata(0)
		if data and data.node.get_child_count() > 0: # 加载子节点
			call_deferred("_load_children_item", item, null)
		return
	var data: NodeData = children.get_metadata(0)
	if !data: # 没有data，说明没有初始化数据，这里也有加载子节点
		if _is_in_select_func:
			_load_children_item(item, children)
		else:
			call_deferred("_load_children_item", item, children)
	else: # 执行更新子节点
		if _is_in_select_func:
			_update_children(item, item.get_metadata(0))
		else:
			call_deferred("_update_children", item, item.get_metadata(0))

func _load_children_item(item: TreeItem, slot: TreeItem, add_slot: bool = true):
	if slot:
		item.remove_child(slot)
	var data: NodeData = item.get_metadata(0)  # 获取存储的节点引用
	if data:
		if !is_instance_valid(data.node): # 节点可能已被删除
			return
		for child in data.node.get_children():
			create_node_item(child, item, add_slot)
			
func get_visible_icon(v: bool) -> Texture:
	return _visible_icon if v else _hide_icon

func create_node_data(node: Node) -> NodeData:
	return NodeData.new(node)
