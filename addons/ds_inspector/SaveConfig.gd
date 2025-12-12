@tool
extends Node
class_name DsSaveConfig

# 数据类定义
class ConfigData:
	var window_size_x: float = 800.0
	var window_size_y: float = 600.0
	var window_position_x: float = 100.0
	var window_position_y: float = 100.0
	var hover_icon_position_x: float = 0.0
	var hover_icon_position_y: float = 0.0
	var exclude_list: Array = []
	var collect_list: Array = []
	var enable_in_editor: bool = false
	var enable_in_game: bool = true
	var use_system_window: bool = false
	var auto_open: bool = false
	var auto_search: bool = false
	var scale_index: int = 2
	var enable_server: bool = true
	var server_port: int = 6004
	var check_viewport: bool = true
	# 是否启用快捷键
	var use_shortcut_key: bool = false
	# 快捷键数据
	var shortcut_key_data: ShortcutKeyData = ShortcutKeyData.new()

# 快捷键数据
class ShortcutKeyData:
	# 隐藏/显示窗口：f5
	var toggle_window: Dictionary = {"keycode": KEY_F5, "ctrl": false, "alt": false, "shift": false, "meta": false}
	# 暂停/播放：ctrl + p
	var pause_play: Dictionary = {"keycode": KEY_P, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 单步执行：ctrl + i
	var step_execute: Dictionary = {"keycode": KEY_I, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 上一个节点：ctrl + 左
	var prev_node: Dictionary = {"keycode": KEY_LEFT, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 下一个节点：ctrl + 右
	var next_node: Dictionary = {"keycode": KEY_RIGHT, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 保存节点：ctrl + s
	var save_node: Dictionary = {"keycode": KEY_S, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 删除节点：ctrl + d
	var delete_node: Dictionary = {"keycode": KEY_D, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 拣选节点：ctrl + =
	var pick_node: Dictionary = {"keycode": KEY_EQUAL, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 收起展开：ctrl + -
	var collapse_expand: Dictionary = {"keycode": KEY_MINUS, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 聚焦搜索节点：ctrl + f
	var focus_search_node: Dictionary = {"keycode": KEY_F, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 聚焦搜索属性：ctrl + g
	var focus_search_attr: Dictionary = {"keycode": KEY_G, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 隐藏/显示选中节点：ctrl + l
	var toggle_selected_node: Dictionary = {"keycode": KEY_L, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 打开选中节点的场景：ctrl + j
	var open_node_scene: Dictionary = {"keycode": KEY_J, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 打开选中节点的脚本：ctrl + k
	var open_node_script: Dictionary = {"keycode": KEY_K, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 记录节点实例：ctrl + \
	var record_node_instance: Dictionary = {"keycode": KEY_BACKSLASH, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 收藏当前路径：ctrl + [
	var collect_path: Dictionary = {"keycode": KEY_BRACKETLEFT, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 排除当前路径：ctrl + ]
	var exclude_path: Dictionary = {"keycode": KEY_BRACKETRIGHT, "ctrl": true, "alt": false, "shift": false, "meta": false}
	# 关闭绘制轮廓：ctrl + ;
	var disable_outline: Dictionary = {"keycode": KEY_SEMICOLON, "ctrl": true, "alt": false, "shift": false, "meta": false}

# 统一的配置文件路径
static var save_path: String = "user://ds_inspector_config.json"

# 配置数据结构
var _config_data: ConfigData

# 延迟保存相关
var _save_timer: float = 0.0
var _needs_save: bool = false
const SAVE_DELAY: float = 1.0

func _init():
	_load_config()
	pass

func _process(delta: float) -> void:
	if _needs_save:
		_save_timer += delta
		if _save_timer >= SAVE_DELAY:
			save_config()
			_needs_save = false
			_save_timer = 0.0

# ==================== 通用方法 ====================

# 序列化值，将Vector2转换为字典
func _serialize_value(value) -> Variant:
	if value is ConfigData:
		return {
			"window_size_x": value.window_size_x,
			"window_size_y": value.window_size_y,
			"window_position_x": value.window_position_x,
			"window_position_y": value.window_position_y,
			"hover_icon_position_x": value.hover_icon_position_x,
			"hover_icon_position_y": value.hover_icon_position_y,
			"exclude_list": value.exclude_list,
			"collect_list": value.collect_list,
			"enable_in_editor": value.enable_in_editor,
			"enable_in_game": value.enable_in_game,
			"use_system_window": value.use_system_window,
			"auto_open": value.auto_open,
			"auto_search": value.auto_search,
			"scale_index": value.scale_index,
			"enable_server": value.enable_server,
			"server_port": value.server_port,
			"check_viewport": value.check_viewport,
			"use_shortcut_key": value.use_shortcut_key,
			"shortcut_key_data": {
				"toggle_window": value.shortcut_key_data.toggle_window,
				"pause_play": value.shortcut_key_data.pause_play,
				"step_execute": value.shortcut_key_data.step_execute,
				"prev_node": value.shortcut_key_data.prev_node,
				"next_node": value.shortcut_key_data.next_node,
				"save_node": value.shortcut_key_data.save_node,
				"delete_node": value.shortcut_key_data.delete_node,
				"pick_node": value.shortcut_key_data.pick_node,
				"collapse_expand": value.shortcut_key_data.collapse_expand,
				"focus_search_node": value.shortcut_key_data.focus_search_node,
				"focus_search_attr": value.shortcut_key_data.focus_search_attr,
				"toggle_selected_node": value.shortcut_key_data.toggle_selected_node,
				"open_node_scene": value.shortcut_key_data.open_node_scene,
				"open_node_script": value.shortcut_key_data.open_node_script,
				"record_node_instance": value.shortcut_key_data.record_node_instance,
				"collect_path": value.shortcut_key_data.collect_path,
				"exclude_path": value.shortcut_key_data.exclude_path,
				"disable_outline": value.shortcut_key_data.disable_outline
			}
		}
	else:
		return value

func _deserialize_value(value) -> Variant:
	var config = ConfigData.new()
	config.window_size_x = value.get("window_size_x", 800.0)
	config.window_size_y = value.get("window_size_y", 600.0)
	config.window_position_x = value.get("window_position_x", 100.0)
	config.window_position_y = value.get("window_position_y", 100.0)
	config.hover_icon_position_x = value.get("hover_icon_position_x", 0.0)
	config.hover_icon_position_y = value.get("hover_icon_position_y", 0.0)
	# 处理可能为 null 的数组字段
	var exclude_list = value.get("exclude_list", [])
	config.exclude_list = exclude_list if exclude_list != null else []
	var collect_list = value.get("collect_list", [])
	config.collect_list = collect_list if collect_list != null else []
	# 处理可能为 null 的布尔字段
	var enable_in_editor = value.get("enable_in_editor", false)
	config.enable_in_editor = enable_in_editor if enable_in_editor != null else false
	var enable_in_game = value.get("enable_in_game", true)
	config.enable_in_game = enable_in_game if enable_in_game != null else true
	var use_system_window = value.get("use_system_window", false)
	config.use_system_window = use_system_window if use_system_window != null else false
	var auto_open = value.get("auto_open", false)
	config.auto_open = auto_open if auto_open != null else false
	var auto_search = value.get("auto_search", false)
	config.auto_search = auto_search if auto_search != null else false
	# 处理可能为 null 的数值字段
	var scale_index = value.get("scale_index", 2)
	config.scale_index = scale_index if scale_index != null else 2
	# 处理可能为 null 的服务器字段
	var enable_server = value.get("enable_server", true)
	config.enable_server = enable_server if enable_server != null else true
	var server_port = value.get("server_port", 6004)
	config.server_port = server_port if server_port != null else 6004
	# 处理可能为 null 的视口检查字段
	var check_viewport = value.get("check_viewport", true)
	config.check_viewport = check_viewport if check_viewport != null else true
	# 处理可能为 null 的快捷键字段
	var use_shortcut_key = value.get("use_shortcut_key", false)
	config.use_shortcut_key = use_shortcut_key if use_shortcut_key != null else false
	# 处理快捷键数据
	var shortcut_data = value.get("shortcut_key_data", {})
	if shortcut_data is Dictionary and shortcut_data.size() > 0:
		config.shortcut_key_data = ShortcutKeyData.new()
		var toggle_window = shortcut_data.get("toggle_window", config.shortcut_key_data.toggle_window)
		config.shortcut_key_data.toggle_window = toggle_window if toggle_window != null else config.shortcut_key_data.toggle_window
		var pause_play = shortcut_data.get("pause_play", config.shortcut_key_data.pause_play)
		config.shortcut_key_data.pause_play = pause_play if pause_play != null else config.shortcut_key_data.pause_play
		var step_execute = shortcut_data.get("step_execute", config.shortcut_key_data.step_execute)
		config.shortcut_key_data.step_execute = step_execute if step_execute != null else config.shortcut_key_data.step_execute
		var prev_node = shortcut_data.get("prev_node", config.shortcut_key_data.prev_node)
		config.shortcut_key_data.prev_node = prev_node if prev_node != null else config.shortcut_key_data.prev_node
		var next_node = shortcut_data.get("next_node", config.shortcut_key_data.next_node)
		config.shortcut_key_data.next_node = next_node if next_node != null else config.shortcut_key_data.next_node
		var save_node = shortcut_data.get("save_node", config.shortcut_key_data.save_node)
		config.shortcut_key_data.save_node = save_node if save_node != null else config.shortcut_key_data.save_node
		var delete_node = shortcut_data.get("delete_node", config.shortcut_key_data.delete_node)
		config.shortcut_key_data.delete_node = delete_node if delete_node != null else config.shortcut_key_data.delete_node
		var pick_node = shortcut_data.get("pick_node", config.shortcut_key_data.pick_node)
		config.shortcut_key_data.pick_node = pick_node if pick_node != null else config.shortcut_key_data.pick_node
		var collapse_expand = shortcut_data.get("collapse_expand", config.shortcut_key_data.collapse_expand)
		config.shortcut_key_data.collapse_expand = collapse_expand if collapse_expand != null else config.shortcut_key_data.collapse_expand
		var focus_search_node = shortcut_data.get("focus_search_node", config.shortcut_key_data.focus_search_node)
		config.shortcut_key_data.focus_search_node = focus_search_node if focus_search_node != null else config.shortcut_key_data.focus_search_node
		var focus_search_attr = shortcut_data.get("focus_search_attr", config.shortcut_key_data.focus_search_attr)
		config.shortcut_key_data.focus_search_attr = focus_search_attr if focus_search_attr != null else config.shortcut_key_data.focus_search_attr
		var toggle_selected_node = shortcut_data.get("toggle_selected_node", config.shortcut_key_data.toggle_selected_node)
		config.shortcut_key_data.toggle_selected_node = toggle_selected_node if toggle_selected_node != null else config.shortcut_key_data.toggle_selected_node
		var open_node_scene = shortcut_data.get("open_node_scene", config.shortcut_key_data.open_node_scene)
		config.shortcut_key_data.open_node_scene = open_node_scene if open_node_scene != null else config.shortcut_key_data.open_node_scene
		var open_node_script = shortcut_data.get("open_node_script", config.shortcut_key_data.open_node_script)
		config.shortcut_key_data.open_node_script = open_node_script if open_node_script != null else config.shortcut_key_data.open_node_script
		var record_node_instance = shortcut_data.get("record_node_instance", config.shortcut_key_data.record_node_instance)
		config.shortcut_key_data.record_node_instance = record_node_instance if record_node_instance != null else config.shortcut_key_data.record_node_instance
		var collect_path = shortcut_data.get("collect_path", config.shortcut_key_data.collect_path)
		config.shortcut_key_data.collect_path = collect_path if collect_path != null else config.shortcut_key_data.collect_path
		var exclude_path = shortcut_data.get("exclude_path", config.shortcut_key_data.exclude_path)
		config.shortcut_key_data.exclude_path = exclude_path if exclude_path != null else config.shortcut_key_data.exclude_path
		var disable_outline = shortcut_data.get("disable_outline", config.shortcut_key_data.disable_outline)
		config.shortcut_key_data.disable_outline = disable_outline if disable_outline != null else config.shortcut_key_data.disable_outline
	else:
		config.shortcut_key_data = ShortcutKeyData.new()
	return config

# 保存所有配置到文件
func save_config() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var serialized_data = _serialize_value(_config_data)
		file.store_string(JSON.stringify(serialized_data, "\t"))
		file.close()
		# print("----------")
		# print("save:", serialized_data)
		# print("配置已保存到 ", save_path)
	else:
		print("无法保存配置文件到 ", save_path)

# 加载配置文件
func _load_config() -> void:
	# print("加载配置文件", save_path)
	if FileAccess.file_exists(save_path):
		var file := FileAccess.open(save_path, FileAccess.READ)
		if file:
			var content := file.get_as_text()
			file.close()
			var json := JSON.new()
			var parse_result = json.parse(content)
			if parse_result == OK:
				var result = json.data
				if result is Dictionary:
					_config_data = _deserialize_value(result)
				else:
					print("配置文件格式错误，使用默认配置")
					_config_data = ConfigData.new()
					save_config()
			else:
				print("JSON 解析错误: ", json.get_error_message())
				_config_data = ConfigData.new()
				save_config()
		else:
			print("无法打开配置文件 ", save_path)
			_config_data = ConfigData.new()
			save_config()
	else:
		# 如果文件不存在，使用默认配置
		_config_data = ConfigData.new()
		save_config()

# 保存窗口状态
func save_window_state(window_size: Vector2, window_position: Vector2) -> void:
	_config_data.window_size_x = window_size.x
	_config_data.window_size_y = window_size.y
	_config_data.window_position_x = window_position.x
	_config_data.window_position_y = window_position.y
	_needs_save = true

# 获取窗口大小
func get_window_size() -> Vector2:
	return Vector2(_config_data.window_size_x, _config_data.window_size_y)

# 获取窗口位置
func get_window_position() -> Vector2:
	return Vector2(_config_data.window_position_x, _config_data.window_position_y)

# ==================== 悬浮图标相关 ====================

# 保存悬浮图标位置
func save_hover_icon_position(pos: Vector2) -> void:
	_config_data.hover_icon_position_x = pos.x
	_config_data.hover_icon_position_y = pos.y
	_needs_save = true

# 获取悬浮图标位置
func get_hover_icon_position() -> Vector2:
	return Vector2(_config_data.hover_icon_position_x, _config_data.hover_icon_position_y)

# ==================== 排除列表相关 ====================

# 保存排除列表
func save_exclude_list(exclude_list: Array) -> void:
	_config_data.exclude_list = exclude_list.duplicate()
	_needs_save = true

# 获取排除列表
func get_exclude_list() -> Array:
	return _config_data.exclude_list.duplicate()

# 添加排除路径
func add_exclude_path(path: String) -> bool:
	if not _config_data.exclude_list.has(path):
		_config_data.exclude_list.append(path)
		_needs_save = true
		return true
	return false

# 移除排除路径
func remove_exclude_path(path: String) -> bool:
	var index: int = _config_data.exclude_list.find(path)
	if index >= 0:
		_config_data.exclude_list.remove_at(index)
		_needs_save = true
		return true
	return false

# 检查路径是否在排除列表中
func has_exclude_path(path: String) -> bool:
	return _config_data.exclude_list.has(path)

# ==================== 收集列表相关 ====================

# 保存收集列表
func save_collect_list(collect_list: Array) -> void:
	_config_data.collect_list = collect_list.duplicate()
	_needs_save = true

# 获取收集列表
func get_collect_list() -> Array:
	return _config_data.collect_list.duplicate()

# 添加收集路径
func add_collect_path(path: String) -> bool:
	if not _config_data.collect_list.has(path):
		_config_data.collect_list.append(path)
		_needs_save = true
		return true
	return false

# 移除收集路径
func remove_collect_path(path: String) -> bool:
	var index: int = _config_data.collect_list.find(path)
	if index >= 0:
		_config_data.collect_list.remove_at(index)
		_needs_save = true
		return true
	return false

# 检查路径是否在收集列表中
func has_collect_path(path: String) -> bool:
	return _config_data.collect_list.has(path)

# ==================== 启用/禁用相关 ====================

# 设置编辑器运行启用状态
func set_enable_in_editor(enabled: bool) -> void:
	_config_data.enable_in_editor = enabled
	_needs_save = true

# 获取编辑器运行启用状态
func get_enable_in_editor() -> bool:
	return _config_data.enable_in_editor

# 设置游戏中运行启用状态
func set_enable_in_game(enabled: bool) -> void:
	_config_data.enable_in_game = enabled
	_needs_save = true

# 获取游戏中运行启用状态
func get_enable_in_game() -> bool:
	return _config_data.enable_in_game

# ==================== Checkbox相关 ====================

# 设置使用系统原生弹窗
func set_use_system_window(enabled: bool) -> void:
	_config_data.use_system_window = enabled
	_needs_save = true

# 获取使用系统原生弹窗
func get_use_system_window() -> bool:
	return _config_data.use_system_window

# 设置启动游戏自动打弹窗
func set_auto_open(enabled: bool) -> void:
	_config_data.auto_open = enabled
	_needs_save = true

# 获取启动游戏自动打弹窗
func get_auto_open() -> bool:
	return _config_data.auto_open

# 设置场景树自动搜索
func set_auto_search(enabled: bool) -> void:
	_config_data.auto_search = enabled
	_needs_save = true

# 获取场景树自动搜索
func get_auto_search() -> bool:
	return _config_data.auto_search

# ==================== 缩放相关 ====================

const SCALE_FACTORS = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]

# 设置缩放索引
func set_scale_index(index: int) -> void:
	_config_data.scale_index = index
	_needs_save = true

# 获取缩放索引
func get_scale_index() -> int:
	return _config_data.scale_index

# 获取缩放因子
func get_scale_factor() -> float:
	if _config_data.scale_index >= 0 and _config_data.scale_index < SCALE_FACTORS.size():
		return SCALE_FACTORS[_config_data.scale_index]
	return 1.0

# ==================== 服务器相关 ====================

# 设置是否开启服务器
func set_enable_server(enabled: bool) -> void:
	_config_data.enable_server = enabled
	_needs_save = true

# 获取是否开启服务器
func get_enable_server() -> bool:
	return _config_data.enable_server

# 设置服务器端口
func set_server_port(port: int) -> void:
	_config_data.server_port = port
	_needs_save = true

# 获取服务器端口
func get_server_port() -> int:
	return _config_data.server_port

# ==================== 视口检查相关 ====================

# 设置检查视口
func set_check_viewport(enabled: bool) -> void:
	_config_data.check_viewport = enabled
	_needs_save = true

# 获取检查视口
func get_check_viewport() -> bool:
	return _config_data.check_viewport

# ==================== 快捷键相关 ====================

# 设置是否启用快捷键
func set_use_shortcut_key(enabled: bool) -> void:
	_config_data.use_shortcut_key = enabled
	_needs_save = true

# 获取是否启用快捷键
func get_use_shortcut_key() -> bool:
	return _config_data.use_shortcut_key

# 设置快捷键数据
func set_shortcut_key_data(data: ShortcutKeyData) -> void:
	_config_data.shortcut_key_data = data
	_needs_save = true

# 获取快捷键数据
func get_shortcut_key_data() -> ShortcutKeyData:
	return _config_data.shortcut_key_data

# 设置隐藏/显示窗口快捷键
func set_toggle_window_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.toggle_window = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取隐藏/显示窗口快捷键
func get_toggle_window_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.toggle_window

# 设置暂停/播放快捷键
func set_pause_play_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.pause_play = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取暂停/播放快捷键
func get_pause_play_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.pause_play

# 设置单步执行快捷键
func set_step_execute_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.step_execute = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取单步执行快捷键
func get_step_execute_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.step_execute

# 设置上一个节点快捷键
func set_prev_node_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.prev_node = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取上一个节点快捷键
func get_prev_node_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.prev_node

# 设置下一个节点快捷键
func set_next_node_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.next_node = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取下一个节点快捷键
func get_next_node_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.next_node

# 设置保存节点快捷键
func set_save_node_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.save_node = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取保存节点快捷键
func get_save_node_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.save_node

# 设置删除节点快捷键
func set_delete_node_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.delete_node = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取删除节点快捷键
func get_delete_node_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.delete_node

# 设置拣选节点快捷键
func set_pick_node_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.pick_node = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取拣选节点快捷键
func get_pick_node_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.pick_node

# 设置收起展开快捷键
func set_collapse_expand_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.collapse_expand = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取收起展开快捷键
func get_collapse_expand_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.collapse_expand

# 设置聚焦搜索节点快捷键
func set_focus_search_node_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.focus_search_node = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取聚焦搜索节点快捷键
func get_focus_search_node_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.focus_search_node

# 设置聚焦搜索属性快捷键
func set_focus_search_attr_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.focus_search_attr = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取聚焦搜索属性快捷键
func get_focus_search_attr_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.focus_search_attr

# 设置隐藏/显示选中节点快捷键
func set_toggle_selected_node_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.toggle_selected_node = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取隐藏/显示选中节点快捷键
func get_toggle_selected_node_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.toggle_selected_node

# 设置打开选中节点的场景快捷键
func set_open_node_scene_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.open_node_scene = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取打开选中节点的场景快捷键
func get_open_node_scene_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.open_node_scene

# 设置打开选中节点的脚本快捷键
func set_open_node_script_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.open_node_script = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取打开选中节点的脚本快捷键
func get_open_node_script_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.open_node_script

# 设置记录节点实例快捷键
func set_record_node_instance_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.record_node_instance = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取记录节点实例快捷键
func get_record_node_instance_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.record_node_instance

# 设置收藏当前路径快捷键
func set_collect_path_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.collect_path = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取收藏当前路径快捷键
func get_collect_path_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.collect_path

# 设置排除当前路径快捷键
func set_exclude_path_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.exclude_path = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取排除当前路径快捷键
func get_exclude_path_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.exclude_path

# 设置关闭绘制轮廓快捷键
func set_disable_outline_shortcut(keycode: int, ctrl: bool = false, alt: bool = false, shift: bool = false, meta: bool = false) -> void:
	_config_data.shortcut_key_data.disable_outline = {"keycode": keycode, "ctrl": ctrl, "alt": alt, "shift": shift, "meta": meta}
	_needs_save = true

# 获取关闭绘制轮廓快捷键
func get_disable_outline_shortcut() -> Dictionary:
	return _config_data.shortcut_key_data.disable_outline