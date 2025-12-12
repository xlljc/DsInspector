@tool
extends VBoxContainer

"""
如果关闭了窗口则不监听其他快捷键（只监听隐藏/显示窗口）
可以自己录制快捷键，支持 ctrl、alt、shift、command 组合键
可以设置是否启用快捷键

默认快捷键：
隐藏/显示窗口：f5
暂停/播放：ctrl + p
单步执行：ctrl + i
上一个节点：ctrl + 左
下一个节点：ctrl + 右
保存节点：ctrl + s
删除节点：ctrl + d
拣选节点：ctrl + =
收起展开：ctrl + -
聚焦搜索节点：ctrl + f
聚焦搜索属性：ctrl + g
隐藏/显示选中节点：ctrl + j
打开选中节点的场景：ctrl + k
打开选中节点的脚本：ctrl + l
记录节点实例：ctrl + \
收藏当前路径：ctrl + [
排除当前路径：ctrl + ]
"""

@export
var debug_tool: CanvasLayer

@export
var shortcut_dialog: ConfirmationDialog

# 快捷键按钮
@export
var toggle_window_btn: Button
@export
var pause_play_btn: Button
@export
var step_execute_btn: Button
@export
var prev_node_btn: Button
@export
var next_node_btn: Button
@export
var save_node_btn: Button
@export
var delete_node_btn: Button
@export
var pick_node_btn: Button
@export
var collapse_expand_btn: Button
@export
var focus_search_node_btn: Button
@export
var focus_search_attr_btn: Button
@export
var toggle_selected_node_btn: Button
@export
var open_node_scene_btn: Button
@export
var open_node_script_btn: Button
@export
var record_node_instance_btn: Button
@export
var collect_path_btn: Button
@export
var exclude_path_btn: Button

# 弹窗中的标签
var _dialog_label: Label
# 输入控件
var _input_control: Control
# 当前正在录制的快捷键名称
var _current_shortcut_name: String = ""
# 录制的键位数据
var _recorded_keycode: int = 0
var _recorded_ctrl: bool = false
var _recorded_alt: bool = false
var _recorded_shift: bool = false
var _recorded_meta: bool = false

# Input Action 名称前缀
const ACTION_PREFIX = "ds_inspector_"

# 快捷键名称到 Action 名称的映射
const SHORTCUT_TO_ACTION = {
	"toggle_window": "ds_inspector_toggle_window",
	"pause_play": "ds_inspector_pause_play",
	"step_execute": "ds_inspector_step_execute",
	"prev_node": "ds_inspector_prev_node",
	"next_node": "ds_inspector_next_node",
	"save_node": "ds_inspector_save_node",
	"delete_node": "ds_inspector_delete_node",
	"pick_node": "ds_inspector_pick_node",
	"collapse_expand": "ds_inspector_collapse_expand",
	"focus_search_node": "ds_inspector_focus_search_node",
	"focus_search_attr": "ds_inspector_focus_search_attr",
	"toggle_selected_node": "ds_inspector_toggle_selected_node",
	"open_node_scene": "ds_inspector_open_node_scene",
	"open_node_script": "ds_inspector_open_node_script",
	"record_node_instance": "ds_inspector_record_node_instance",
	"collect_path": "ds_inspector_collect_path",
	"exclude_path": "ds_inspector_exclude_path"
}

func _ready():
	if !debug_tool:
		return
	
	# 初始化弹窗
	_setup_dialog()
	
	# 连接所有按钮的点击事件
	toggle_window_btn.pressed.connect(_on_shortcut_btn_pressed.bind("toggle_window", "隐藏/显示窗口"))
	pause_play_btn.pressed.connect(_on_shortcut_btn_pressed.bind("pause_play", "暂停/播放"))
	step_execute_btn.pressed.connect(_on_shortcut_btn_pressed.bind("step_execute", "单步执行"))
	prev_node_btn.pressed.connect(_on_shortcut_btn_pressed.bind("prev_node", "上一个节点"))
	next_node_btn.pressed.connect(_on_shortcut_btn_pressed.bind("next_node", "下一个节点"))
	save_node_btn.pressed.connect(_on_shortcut_btn_pressed.bind("save_node", "保存节点"))
	delete_node_btn.pressed.connect(_on_shortcut_btn_pressed.bind("delete_node", "删除节点"))
	pick_node_btn.pressed.connect(_on_shortcut_btn_pressed.bind("pick_node", "拣选节点"))
	collapse_expand_btn.pressed.connect(_on_shortcut_btn_pressed.bind("collapse_expand", "收起展开"))
	focus_search_node_btn.pressed.connect(_on_shortcut_btn_pressed.bind("focus_search_node", "聚焦搜索节点"))
	focus_search_attr_btn.pressed.connect(_on_shortcut_btn_pressed.bind("focus_search_attr", "聚焦搜索属性"))
	toggle_selected_node_btn.pressed.connect(_on_shortcut_btn_pressed.bind("toggle_selected_node", "隐藏/显示选中节点"))
	open_node_scene_btn.pressed.connect(_on_shortcut_btn_pressed.bind("open_node_scene", "打开选中节点的场景"))
	open_node_script_btn.pressed.connect(_on_shortcut_btn_pressed.bind("open_node_script", "打开选中节点的脚本"))
	record_node_instance_btn.pressed.connect(_on_shortcut_btn_pressed.bind("record_node_instance", "记录节点实例"))
	collect_path_btn.pressed.connect(_on_shortcut_btn_pressed.bind("collect_path", "收藏当前路径"))
	exclude_path_btn.pressed.connect(_on_shortcut_btn_pressed.bind("exclude_path", "排除当前路径"))
	
	# 初始化所有 Input Action
	_init_input_actions()
	
	# 加载并显示当前的快捷键
	_load_shortcuts()

func _exit_tree():
	"""节点退出时清理 Input Actions"""
	_cleanup_input_actions()

func _cleanup_input_actions():
	"""清理所有创建的 Input Action"""
	for action_name in SHORTCUT_TO_ACTION.values():
		if InputMap.has_action(action_name):
			InputMap.erase_action(action_name)

func _init_input_actions():
	"""初始化所有 Input Action"""
	if !debug_tool or !debug_tool.save_config:
		return
	
	var shortcut_data = debug_tool.save_config.get_shortcut_key_data()
	
	# 为每个快捷键创建对应的 Action
	_create_or_update_action("toggle_window", shortcut_data.toggle_window)
	_create_or_update_action("pause_play", shortcut_data.pause_play)
	_create_or_update_action("step_execute", shortcut_data.step_execute)
	_create_or_update_action("prev_node", shortcut_data.prev_node)
	_create_or_update_action("next_node", shortcut_data.next_node)
	_create_or_update_action("save_node", shortcut_data.save_node)
	_create_or_update_action("delete_node", shortcut_data.delete_node)
	_create_or_update_action("pick_node", shortcut_data.pick_node)
	_create_or_update_action("collapse_expand", shortcut_data.collapse_expand)
	_create_or_update_action("focus_search_node", shortcut_data.focus_search_node)
	_create_or_update_action("focus_search_attr", shortcut_data.focus_search_attr)
	_create_or_update_action("toggle_selected_node", shortcut_data.toggle_selected_node)
	_create_or_update_action("open_node_scene", shortcut_data.open_node_scene)
	_create_or_update_action("open_node_script", shortcut_data.open_node_script)
	_create_or_update_action("record_node_instance", shortcut_data.record_node_instance)
	_create_or_update_action("collect_path", shortcut_data.collect_path)
	_create_or_update_action("exclude_path", shortcut_data.exclude_path)

func _create_or_update_action(shortcut_name: String, shortcut_dict: Dictionary):
	"""创建或更新一个 Input Action"""
	if shortcut_dict.is_empty():
		return
	
	var action_name = SHORTCUT_TO_ACTION.get(shortcut_name, "")
	if action_name.is_empty():
		return
	
	# 如果 Action 不存在，创建它
	if !InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	else:
		# 清除现有的事件
		InputMap.action_erase_events(action_name)
	
	# 创建键盘事件
	var event = InputEventKey.new()
	event.keycode = shortcut_dict.get("keycode", 0)
	event.ctrl_pressed = shortcut_dict.get("ctrl", false)
	event.alt_pressed = shortcut_dict.get("alt", false)
	event.shift_pressed = shortcut_dict.get("shift", false)
	event.meta_pressed = shortcut_dict.get("meta", false)
	
	# 添加事件到 Action
	InputMap.action_add_event(action_name, event)

func _setup_dialog():
	if !shortcut_dialog:
		return
	
	# 设置弹窗标题
	shortcut_dialog.title = "录制快捷键"
	shortcut_dialog.ok_button_text = "确定"
	shortcut_dialog.cancel_button_text = "取消"
	
	# 创建一个控件来接收输入
	_input_control = Control.new()
	_input_control.custom_minimum_size = Vector2(280, 80)
	_input_control.focus_mode = Control.FOCUS_ALL
	_input_control.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# 创建标签显示提示信息
	_dialog_label = Label.new()
	_dialog_label.text = "请按下键盘快捷键..."
	_dialog_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dialog_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_dialog_label.custom_minimum_size = Vector2(280, 80)
	_dialog_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialog_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_input_control.add_child(_dialog_label)
	
	shortcut_dialog.add_child(_input_control)
	
	# 连接输入事件
	_input_control.gui_input.connect(_on_dialog_input)
	
	# 连接确认和取消信号
	shortcut_dialog.confirmed.connect(_on_dialog_confirmed)
	shortcut_dialog.canceled.connect(_on_dialog_canceled)

func _on_shortcut_btn_pressed(shortcut_name: String, display_name: String):
	_current_shortcut_name = shortcut_name
	_recorded_keycode = 0
	_recorded_ctrl = false
	_recorded_alt = false
	_recorded_shift = false
	_recorded_meta = false
	
	_dialog_label.text = "请按下键盘快捷键..."
	shortcut_dialog.popup_centered()
	# 延迟设置焦点到输入控件，确保弹窗已完全显示
	_input_control.call_deferred("grab_focus")

func _on_dialog_input(event: InputEvent):
	# 监听弹窗中的键盘输入
	if event is InputEventKey and event.pressed:
		# 忽略修饰键本身
		if event.keycode in [KEY_CTRL, KEY_SHIFT, KEY_ALT, KEY_META]:
			return
		
		# 记录键码和修饰键
		_recorded_keycode = event.keycode
		_recorded_ctrl = event.ctrl_pressed
		_recorded_alt = event.alt_pressed
		_recorded_shift = event.shift_pressed
		_recorded_meta = event.meta_pressed
		
		# 显示录制的快捷键
		var shortcut_text = _get_shortcut_text(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		_dialog_label.text = "录制到的快捷键：\n" + shortcut_text
		
		# 接受事件，防止传递
		_input_control.accept_event()

func _on_dialog_confirmed():
	if _current_shortcut_name.is_empty() or _recorded_keycode == 0:
		return
	
	# 保存快捷键到配置
	var save_config = debug_tool.save_config
	match _current_shortcut_name:
		"toggle_window":
			save_config.set_toggle_window_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"pause_play":
			save_config.set_pause_play_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"step_execute":
			save_config.set_step_execute_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"prev_node":
			save_config.set_prev_node_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"next_node":
			save_config.set_next_node_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"save_node":
			save_config.set_save_node_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"delete_node":
			save_config.set_delete_node_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"pick_node":
			save_config.set_pick_node_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"collapse_expand":
			save_config.set_collapse_expand_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"focus_search_node":
			save_config.set_focus_search_node_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"focus_search_attr":
			save_config.set_focus_search_attr_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"toggle_selected_node":
			save_config.set_toggle_selected_node_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"open_node_scene":
			save_config.set_open_node_scene_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"open_node_script":
			save_config.set_open_node_script_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"record_node_instance":
			save_config.set_record_node_instance_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"collect_path":
			save_config.set_collect_path_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
		"exclude_path":
			save_config.set_exclude_path_shortcut(_recorded_keycode, _recorded_ctrl, _recorded_alt, _recorded_shift, _recorded_meta)
	
	# 更新对应的 Input Action
	var shortcut_dict = {
		"keycode": _recorded_keycode,
		"ctrl": _recorded_ctrl,
		"alt": _recorded_alt,
		"shift": _recorded_shift,
		"meta": _recorded_meta
	}
	_create_or_update_action(_current_shortcut_name, shortcut_dict)
	
	# 更新按钮显示
	_load_shortcuts()

func _on_dialog_canceled():
	_current_shortcut_name = ""

func _load_shortcuts():
	if !debug_tool or !debug_tool.save_config:
		return
	
	var save_config = debug_tool.save_config
	var shortcut_data = save_config.get_shortcut_key_data()
	
	# 更新所有按钮的文本
	_update_button_text(toggle_window_btn, shortcut_data.toggle_window)
	_update_button_text(pause_play_btn, shortcut_data.pause_play)
	_update_button_text(step_execute_btn, shortcut_data.step_execute)
	_update_button_text(prev_node_btn, shortcut_data.prev_node)
	_update_button_text(next_node_btn, shortcut_data.next_node)
	_update_button_text(save_node_btn, shortcut_data.save_node)
	_update_button_text(delete_node_btn, shortcut_data.delete_node)
	_update_button_text(pick_node_btn, shortcut_data.pick_node)
	_update_button_text(collapse_expand_btn, shortcut_data.collapse_expand)
	_update_button_text(focus_search_node_btn, shortcut_data.focus_search_node)
	_update_button_text(focus_search_attr_btn, shortcut_data.focus_search_attr)
	_update_button_text(toggle_selected_node_btn, shortcut_data.toggle_selected_node)
	_update_button_text(open_node_scene_btn, shortcut_data.open_node_scene)
	_update_button_text(open_node_script_btn, shortcut_data.open_node_script)
	_update_button_text(record_node_instance_btn, shortcut_data.record_node_instance)
	_update_button_text(collect_path_btn, shortcut_data.collect_path)
	_update_button_text(exclude_path_btn, shortcut_data.exclude_path)

func _update_button_text(button: Button, shortcut_dict: Dictionary):
	if !button or shortcut_dict.is_empty():
		return
	
	var keycode = shortcut_dict.get("keycode", 0)
	var ctrl = shortcut_dict.get("ctrl", false)
	var alt = shortcut_dict.get("alt", false)
	var shift = shortcut_dict.get("shift", false)
	var meta = shortcut_dict.get("meta", false)
	
	button.text = _get_shortcut_text(keycode, ctrl, alt, shift, meta)

func get_action_name(shortcut_name: String) -> String:
	"""获取快捷键对应的 Action 名称"""
	return SHORTCUT_TO_ACTION.get(shortcut_name, "")

func is_shortcut_pressed(shortcut_name: String) -> bool:
	"""检查快捷键是否被按下"""
	var action_name = get_action_name(shortcut_name)
	if action_name.is_empty() or !InputMap.has_action(action_name):
		return false
	return Input.is_action_pressed(action_name)

func is_shortcut_just_pressed(shortcut_name: String) -> bool:
	"""检查快捷键是否刚被按下"""
	var action_name = get_action_name(shortcut_name)
	if action_name.is_empty() or !InputMap.has_action(action_name):
		return false
	return Input.is_action_just_pressed(action_name)

func is_recording() -> bool:
	"""检查是否正在录制快捷键"""
	return shortcut_dialog != null and shortcut_dialog.visible

func _get_shortcut_text(keycode: int, ctrl: bool, alt: bool, shift: bool, meta: bool) -> String:
	var parts: Array[String] = []
	
	if ctrl:
		parts.append("Ctrl")
	if alt:
		parts.append("Alt")
	if shift:
		parts.append("Shift")
	if meta:
		parts.append("Cmd")
	
	# 获取键名
	var key_name = OS.get_keycode_string(keycode)
	
	# 将特殊符号键转换为实际符号显示
	var symbol_map = {
		"Equal": "=",
		"Minus": "-",
		"BracketLeft": "[",
		"BracketRight": "]",
		"BackSlash": "\\",
		"Semicolon": ";",
		"Apostrophe": "'",
		"Comma": ",",
		"Period": ".",
		"Slash": "/"
	}
	
	if symbol_map.has(key_name):
		key_name = symbol_map[key_name]
	
	if !key_name.is_empty():
		parts.append(key_name)
	
	return " + ".join(parts)