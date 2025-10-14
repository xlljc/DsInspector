@tool
extends Node
class_name SaveConfig

# 数据类定义
class WindowConfig:
	var size: Vector2
	var position: Vector2
	
	func _init(s: Vector2 = Vector2(800, 600), p: Vector2 = Vector2(100, 100)):
		size = s
		position = p

class HoverIconConfig:
	var position: Vector2
	
	func _init(p: Vector2 = Vector2(0, 0)):
		position = p

class ConfigData:
	var window: WindowConfig
	var hover_icon: HoverIconConfig
	var exclude_list: Array
	var enable_in_editor: bool
	var enable_in_game: bool
	
	func _init():
		window = WindowConfig.new()
		hover_icon = HoverIconConfig.new()
		exclude_list = []
		enable_in_editor = false
		enable_in_game = true

# 统一的配置文件路径
static var save_path: String = "user://ds_inspector_config.json"

# 配置数据结构
var _config_data: ConfigData = ConfigData.new()

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
	if value is Vector2:
		return {"x": value.x, "y": value.y}
	elif value is ConfigData:
		return {
			"window": _serialize_value(value.window),
			"hover_icon": _serialize_value(value.hover_icon),
			"exclude_list": value.exclude_list,
			"enable_in_editor": value.enable_in_editor,
			"enable_in_game": value.enable_in_game
		}
	elif value is WindowConfig:
		return {
			"size": _serialize_value(value.size),
			"position": _serialize_value(value.position)
		}
	elif value is HoverIconConfig:
		return {
			"position": _serialize_value(value.position)
		}
	elif value is Dictionary:
		var result = {}
		for key in value:
			result[key] = _serialize_value(value[key])
		return result
	elif value is Array:
		var result = []
		for item in value:
			result.append(_serialize_value(item))
		return result
	else:
		return value

func _deserialize_value(value) -> Variant:
	if value is Dictionary and value.has("x") and value.has("y"):
		return Vector2(value.x, value.y)
	elif value is Dictionary and value.has("window") and value.has("hover_icon") and value.has("exclude_list"):
		var config = ConfigData.new()
		config.window = _deserialize_value(value.window)
		config.hover_icon = _deserialize_value(value.hover_icon)
		config.exclude_list = _deserialize_value(value.exclude_list)
		config.enable_in_editor = value.get("enable_in_editor", true)
		config.enable_in_game = value.get("enable_in_game", true)
		return config
	elif value is Dictionary and value.has("size") and value.has("position"):
		return WindowConfig.new(_deserialize_value(value.size), _deserialize_value(value.position))
	elif value is Dictionary and value.has("position") and not value.has("size"):
		return HoverIconConfig.new(_deserialize_value(value.position))
	elif value is Dictionary:
		var result = {}
		for key in value:
			result[key] = _deserialize_value(value[key])
		return result
	elif value is Array:
		var result = []
		for item in value:
			result.append(_deserialize_value(item))
		return result
	else:
		return value

# 保存所有配置到文件
func save_config() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var serialized_data = _serialize_value(_config_data)
		file.store_string(JSON.stringify(serialized_data, "\t"))
		file.close()
		print("配置已保存到 ", save_path)
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
					var deserialized_result = _deserialize_value(result)
					_config_data = _merge_config(deserialized_result, _config_data)
				else:
					print("配置文件格式错误，使用默认配置")
			else:
				print("JSON 解析错误: ", json.get_error_message())
		else:
			print("无法打开配置文件 ", save_path)

# 合并配置（保留默认值）
func _merge_config(loaded: ConfigData, defaults: ConfigData) -> ConfigData:
	var result = ConfigData.new()
	result.window.size = loaded.window.size if loaded.window.size != Vector2.ZERO else defaults.window.size
	result.window.position = loaded.window.position if loaded.window.position != Vector2.ZERO else defaults.window.position
	result.hover_icon.position = loaded.hover_icon.position if loaded.hover_icon.position != Vector2.ZERO else defaults.hover_icon.position
	result.exclude_list = loaded.exclude_list.duplicate() if loaded.exclude_list.size() > 0 else defaults.exclude_list.duplicate()
	result.enable_in_editor = loaded.enable_in_editor
	result.enable_in_game = loaded.enable_in_game
	return result

# 保存窗口状态
func save_window_state(window_size: Vector2, window_position: Vector2) -> void:
	_config_data.window.size = window_size
	_config_data.window.position = window_position
	_needs_save = true

# 获取窗口大小
func get_window_size() -> Vector2:
	return _config_data.window.size

# 获取窗口位置
func get_window_position() -> Vector2:
	return _config_data.window.position

# ==================== 悬浮图标相关 ====================

# 保存悬浮图标位置
func save_hover_icon_position(pos: Vector2) -> void:
	_config_data.hover_icon.position = pos
	_needs_save = true

# 获取悬浮图标位置
func get_hover_icon_position() -> Vector2:
	return _config_data.hover_icon.position

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