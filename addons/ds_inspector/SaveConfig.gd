@tool
extends Node
class_name SaveConfig

# 数据类定义
class ConfigData:
	var window_size_x: float = 800.0
	var window_size_y: float = 600.0
	var window_position_x: float = 100.0
	var window_position_y: float = 100.0
	var hover_icon_position_x: float = 0.0
	var hover_icon_position_y: float = 0.0
	var exclude_list: Array = []
	var enable_in_editor: bool = false
	var enable_in_game: bool = true
	var use_system_window: bool = false
	var auto_open: bool = false
	var auto_search: bool = false
	var scale_index: int = 2

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
			"enable_in_editor": value.enable_in_editor,
			"enable_in_game": value.enable_in_game,
			"use_system_window": value.use_system_window,
			"auto_open": value.auto_open,
			"auto_search": value.auto_search,
			"scale_index": value.scale_index
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
	config.exclude_list = value.get("exclude_list", [])
	config.enable_in_editor = value.get("enable_in_editor", false)
	config.enable_in_game = value.get("enable_in_game", true)
	config.use_system_window = value.get("use_system_window", false)
	config.auto_open = value.get("auto_open", false)
	config.auto_search = value.get("auto_search", false)
	config.scale_index = value.get("scale_index", 2)
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
