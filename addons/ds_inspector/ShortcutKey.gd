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
	
	# 如果窗口关闭，只监听 toggle_window，其他快捷键不处理
	if !window_visible:
		return
	
	# 窗口打开时，监听其他所有快捷键
	if _check_shortcut("pause_play"):
		_on_pause_play()
	
	if _check_shortcut("step_execute"):
		_on_step_execute()
	
	if _check_shortcut("prev_node"):
		_on_prev_node()
	
	if _check_shortcut("next_node"):
		_on_next_node()
	
	if _check_shortcut("save_node"):
		_on_save_node()
	
	if _check_shortcut("delete_node"):
		_on_delete_node()
	
	if _check_shortcut("pick_node"):
		_on_pick_node()
	
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

func _check_shortcut(shortcut_name: String) -> bool:
	"""检查快捷键是否刚被按下"""
	if !shortcut_key_setting:
		return false
	return shortcut_key_setting.is_shortcut_just_pressed(shortcut_name)


func _on_toggle_window():
	print("[ShortcutKey] 触发：隐藏/显示窗口")

func _on_pause_play():
	print("[ShortcutKey] 触发：暂停/播放")

func _on_step_execute():
	print("[ShortcutKey] 触发：单步执行")

func _on_prev_node():
	print("[ShortcutKey] 触发：上一个节点")

func _on_next_node():
	print("[ShortcutKey] 触发：下一个节点")

func _on_save_node():
	print("[ShortcutKey] 触发：保存节点")

func _on_delete_node():
	print("[ShortcutKey] 触发：删除节点")

func _on_pick_node():
	print("[ShortcutKey] 触发：拣选节点")

func _on_collapse_expand():
	print("[ShortcutKey] 触发：收起展开")

func _on_focus_search_node():
	print("[ShortcutKey] 触发：聚焦搜索节点")

func _on_focus_search_attr():
	print("[ShortcutKey] 触发：聚焦搜索属性")

func _on_toggle_selected_node():
	print("[ShortcutKey] 触发：隐藏/显示选中节点")

func _on_open_node_scene():
	print("[ShortcutKey] 触发：打开选中节点的场景")

func _on_open_node_script():
	print("[ShortcutKey] 触发：打开选中节点的脚本")

func _on_record_node_instance():
	print("[ShortcutKey] 触发：记录节点实例")

func _on_collect_path():
	print("[ShortcutKey] 触发：收藏当前路径")

func _on_exclude_path():
	print("[ShortcutKey] 触发：排除当前路径")