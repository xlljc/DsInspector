@tool
extends Node
class_name DsShortcutKey

"""
快捷键监听器
- 如果关闭了窗口则不监听其他快捷键（只监听隐藏/显示窗口）
- 如果正在录制快捷键，则不监听任何快捷键
"""

@export
var debug_tool: CanvasLayer
@export
var shortcut_key_setting: VBoxContainer
@export
var tab_container: TabContainer
@export
var search_node_input: LineEdit
@export
var search_tree_input: LineEdit
# 收藏节点
@export
var collect_node_btn: Button
# 排除节点
@export
var exclude_node_btn: Button
# 记录展开
@export
var record_expand_btn: Button
# 记录区域
@export
var record_container: Control

# ==================== 快捷键触发的按钮 ====================

func _ready():
	pass

func _process(delta: float):
	# 检查是否正在录制快捷键
	if shortcut_key_setting and shortcut_key_setting.is_recording():
		return
	
	# 检查是否启用快捷键
	if !debug_tool or !debug_tool.save_config or !debug_tool.save_config.get_use_shortcut_key():
		return
	
	# 检查窗口是否显示
	var window_visible = debug_tool.window and debug_tool.window.visible
	
	# 总是监听 toggle_window（切换窗口显示/隐藏）
	if _check_shortcut("toggle_window"):
		_on_toggle_window()
	
	if _check_shortcut("pause_play"):
		_on_pause_play()
	
	if _check_shortcut("step_execute"):
		_on_step_execute()

	if _check_shortcut("pick_node"):
		_on_pick_node()

	# 如果窗口关闭，只监听 toggle_window，其他快捷键不处理
	if !window_visible:
		return
	
	# 窗口打开时，监听其他所有快捷键
	if _check_shortcut("prev_node"):
		_on_prev_node()
	
	if _check_shortcut("next_node"):
		_on_next_node()
	
	if _check_shortcut("save_node"):
		_on_save_node()
	
	if _check_shortcut("delete_node"):
		_on_delete_node()
	
	if _check_shortcut("collapse_expand"):
		_on_collapse_expand()
	
	if _check_shortcut("focus_search_node"):
		_on_focus_search_node()
	
	if _check_shortcut("focus_search_attr"):
		_on_focus_search_attr()
	
	if _check_shortcut("toggle_selected_node"):
		_on_toggle_selected_node()
	
	if _check_shortcut("open_node_scene"):
		_on_open_node_scene()
	
	if _check_shortcut("open_node_script"):
		_on_open_node_script()
	
	if _check_shortcut("record_node_instance"):
		_on_record_node_instance()
	
	if _check_shortcut("collect_path"):
		_on_collect_path()
	
	if _check_shortcut("exclude_path"):
		_on_exclude_path()
	
	if _check_shortcut("disable_outline"):
		_on_disable_outline()

func _check_shortcut(shortcut_name: String) -> bool:
	"""检查快捷键是否刚被按下"""
	if !shortcut_key_setting:
		return false
	return shortcut_key_setting.is_shortcut_just_pressed(shortcut_name)


func _on_toggle_window():
	debug_tool.hover_iton._on_HoverIcon_pressed()
	# print("[ShortcutKey] 触发：隐藏/显示窗口")

func _on_pause_play():
	debug_tool.window.play_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：暂停/播放")

func _on_step_execute():
	debug_tool.window.next_frame_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：单步执行")

func _on_prev_node():
	debug_tool.window.prev_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：上一个节点")

func _on_next_node():
	debug_tool.window.next_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：下一个节点")

func _on_save_node():
	debug_tool.window.save_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：保存节点")

func _on_delete_node():
	debug_tool.window.delete_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：删除节点")

func _on_pick_node():
	debug_tool.window.select_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：拣选节点")

func _on_disable_outline():
	debug_tool.window.hide_border_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：关闭绘制轮廓")

func _on_collapse_expand():
	debug_tool.window.put_away.emit_signal("pressed")
	# print("[ShortcutKey] 触发：收起展开")

func _on_focus_search_node():
	search_node_input.grab_focus()
	# print("[ShortcutKey] 触发：聚焦搜索节点")

func _on_focus_search_attr():
	tab_container.current_tab = 0
	search_tree_input.grab_focus()
	# print("[ShortcutKey] 触发：聚焦搜索属性")

func _on_toggle_selected_node():
	# 获取选中的 TreeItem
	var selected_item: TreeItem = debug_tool.window.tree.get_selected()
	if !selected_item:
		return
	
	# 获取节点数据
	var data = selected_item.get_metadata(0)
	if !data or !is_instance_valid(data.node):
		return
	
	var node: Node = data.node
	# 检查节点是否支持可见性切换
	if node is CanvasItem or node is Control or node is CanvasLayer:
		# 切换节点的可见性
		data.visible = !node.visible
		node.visible = data.visible
		# 更新按钮图标
		if data.visible_icon_index >= 0:
			selected_item.set_button(0, data.visible_icon_index, debug_tool.window.tree.get_visible_icon(data.visible))
	# print("[ShortcutKey] 触发：隐藏/显示选中节点")

func _on_open_node_scene():
	# 获取选中的 TreeItem
	var selected_item: TreeItem = debug_tool.window.tree.get_selected()
	if !selected_item:
		return
	
	# 获取节点数据
	var data = selected_item.get_metadata(0)
	if !data or !is_instance_valid(data.node):
		return
	
	var node: Node = data.node
	# 检查节点是否有场景文件路径
	if node.scene_file_path != "":
		debug_tool.window.tree._open_scene_in_editor(node.scene_file_path)
	# print("[ShortcutKey] 触发：打开选中节点的场景")

func _on_open_node_script():
	# 获取选中的 TreeItem
	var selected_item: TreeItem = debug_tool.window.tree.get_selected()
	if !selected_item:
		return
	
	# 获取节点数据
	var data = selected_item.get_metadata(0)
	if !data or !is_instance_valid(data.node):
		return
	
	var node: Node = data.node
	# 检查节点是否有脚本
	var script: Script = node.get_script()
	if script:
		var res_path: String = script.get_path()
		debug_tool.window.tree._open_script_in_editor(res_path)
	# print("[ShortcutKey] 触发：打开选中节点的脚本")

func _on_record_node_instance():
	# 获取选中的 TreeItem
	var selected_item: TreeItem = debug_tool.window.tree.get_selected()
	if !selected_item:
		return
	
	# 获取节点数据
	var data = selected_item.get_metadata(0)
	if !data or !is_instance_valid(data.node):
		return
	
	var node: Node = data.node
	# 不允许记录根节点
	if node == get_tree().root:
		return
	
	# 检查记录容器是否存在
	if !record_container:
		return
	
	# 检查节点是否已经被记录过
	var node_path: String = str(node.get_path())
	if record_container.recorded_nodes.has(node_path):
		print("节点已经被记录: ", node.name)
		return
	
	# 检查记录区域是否展开，如果未展开则展开
	if record_expand_btn:
		# 检查是否已展开，如果未展开则展开
		if !record_expand_btn.is_expand:
			record_expand_btn.is_expand = true
			record_expand_btn._set_expand_state(true)
	
	# 调用记录容器添加记录项
	record_container._add_record_item(node)
	print("[ShortcutKey] 触发：记录节点实例")

func _on_collect_path():
	tab_container.current_tab = 1
	collect_node_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：收藏当前路径")

func _on_exclude_path():
	tab_container.current_tab = 2
	exclude_node_btn.emit_signal("pressed")
	# print("[ShortcutKey] 触发：排除当前路径")