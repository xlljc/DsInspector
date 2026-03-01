@tool
extends VBoxContainer

@export
var debug_tool: CanvasLayer
@export
var tree_container: VBoxContainer

@export
var local_label: Label
@export
var local_option: OptionButton

@export
var use_system_window_label: Label
@export
var use_system_window_checkbox: CheckBox

@export
var auto_open_label: Label
@export
var auto_open_checkbox: CheckBox

@export
var auto_search_label: Label
@export
var auto_search_checkbox: CheckBox

@export
var scale_label: Label
@export
var scale_options: OptionButton

@export
var server_label: Label
@export
var server_checkbox: CheckBox

@export
var server_port_label: Label
@export
var server_port_input: LineEdit
@export
var server_port_container: HBoxContainer

@export
var check_viewport_label: Label
@export
var check_viewport_checkbox: CheckBox

@export
var shortcut_key_label: Label
@export
var shortcut_key_checkbox: CheckBox
@export
var shortcut_key_container: VBoxContainer

@export
var link_btn: LinkButton

func _ready():
	debug_tool.local.change_language.connect(_on_language_changed)
	_on_language_changed()
	# 读取并设置 checkbox 状态
	if !Engine.is_editor_hint():
		use_system_window_checkbox.button_pressed = debug_tool.save_config.get_use_system_window()
		use_system_window_checkbox.toggled.connect(_on_use_system_window_toggled)
		use_system_window_checkbox.get_parent().visible = true
		server_port_container.get_parent().visible = true
	else:
		use_system_window_checkbox.get_parent().visible = false
		server_port_container.get_parent().visible = false

	# 访问 Localization.gd
	# var local = debug_tool.local
	# 需要初始化 local_option 中的语言
	_init_language_options()

	# 绑定语言切换选项，然后要保存到配置文件中
	local_option.item_selected.connect(_on_language_selected)

	auto_open_checkbox.button_pressed = debug_tool.save_config.get_auto_open()
	auto_open_checkbox.toggled.connect(_on_auto_open_toggled)
	
	auto_search_checkbox.button_pressed = debug_tool.save_config.get_auto_search()
	auto_search_checkbox.toggled.connect(_on_auto_search_toggled)		

	scale_options.selected = debug_tool.save_config.get_scale_index()
	scale_options.item_selected.connect(_on_scale_options_selected)

	# 服务器设置
	server_checkbox.button_pressed = debug_tool.save_config.get_enable_server()
	server_checkbox.toggled.connect(_on_server_checkbox_toggled)
	server_port_input.text = str(debug_tool.save_config.get_server_port())
	server_port_input.text_submitted.connect(_on_server_port_submitted)
	server_port_input.focus_exited.connect(_on_server_port_focus_exited)
	_update_server_port_visibility()

	# 视口检查设置
	check_viewport_checkbox.button_pressed = debug_tool.save_config.get_check_viewport()
	check_viewport_checkbox.toggled.connect(_on_check_viewport_toggled)

	# 快捷键设置
	shortcut_key_checkbox.button_pressed = debug_tool.save_config.get_use_shortcut_key()
	shortcut_key_checkbox.toggled.connect(_on_shortcut_key_toggled)
	_update_shortcut_key_visibility()

	call_deferred("init_config")

func _on_language_changed():
	local_label.text = debug_tool.local.get_str("language")
	use_system_window_label.text = debug_tool.local.get_str("use_native_dialog")
	auto_open_label.text = debug_tool.local.get_str("auto_open_dialog_on_game_start")
	auto_search_label.text = debug_tool.local.get_str("scene_tree_auto_search")
	scale_label.text = debug_tool.local.get_str("ui_scale")
	server_label.text = debug_tool.local.get_str("remote_notify_godot_editor")
	server_port_label.text = debug_tool.local.get_str("server_port")
	check_viewport_label.text = debug_tool.local.get_str("allow_pick_viewport_window")
	shortcut_key_label.text = debug_tool.local.get_str("enable_keyboard_shortcuts")
	link_btn.text = debug_tool.local.get_str("feedback_on_github")

func init_config():
	# 自动打开窗口
	if debug_tool.save_config and debug_tool.save_config.get_auto_open():
		debug_tool.window.call_deferred("do_show")
	# 自动搜索
	_refresh_auto_search()
	# 缩放
	_apply_scale()

func _refresh_auto_search():
	tree_container.set_auto_search_enabled(debug_tool.save_config.get_auto_search())

func _on_use_system_window_toggled(enabled: bool):
	debug_tool.save_config.set_use_system_window(enabled)

func _on_auto_open_toggled(enabled: bool):
	debug_tool.save_config.set_auto_open(enabled)

func _on_auto_search_toggled(enabled: bool):
	debug_tool.save_config.set_auto_search(enabled)
	_refresh_auto_search()

func _on_scale_options_selected(index: int):
	debug_tool.save_config.set_scale_index(index)
	_apply_scale()

func _apply_scale():
	var factor = debug_tool.save_config.get_scale_factor()
	debug_tool.window.content_scale_factor = factor

func _on_server_checkbox_toggled(enabled: bool):
	debug_tool.save_config.set_enable_server(enabled)
	_update_server_port_visibility()

func _update_server_port_visibility():
	var enabled = debug_tool.save_config.get_enable_server()
	server_port_container.visible = enabled

func _on_server_port_submitted(_text: String):
	_save_server_port()

func _on_server_port_focus_exited():
	_save_server_port()

func _save_server_port():
	var port_text = server_port_input.text.strip_edges()
	if port_text.is_valid_int():
		var port = port_text.to_int()
		if port > 0 and port <= 65535:
			debug_tool.save_config.set_server_port(port)
		else:
			# 端口范围无效，恢复为当前配置值
			server_port_input.text = str(debug_tool.save_config.get_server_port())
	else:
		# 输入无效，恢复为当前配置值
		server_port_input.text = str(debug_tool.save_config.get_server_port())

func _on_check_viewport_toggled(enabled: bool):
	debug_tool.save_config.set_check_viewport(enabled)

func _on_shortcut_key_toggled(enabled: bool):
	debug_tool.save_config.set_use_shortcut_key(enabled)
	_update_shortcut_key_visibility()

func _update_shortcut_key_visibility():
	var enabled = debug_tool.save_config.get_use_shortcut_key()
	shortcut_key_container.visible = enabled

# 初始化语言选项
func _init_language_options():
	local_option.clear()
	var local = debug_tool.local
	
	# 获取保存的语言设置（SaveConfig 已在初始化时检测系统语言）
	var saved_language = debug_tool.save_config.get_language()
	
	# 遍历所有可用语言并添加到选项中
	var index = 0
	var selected_index = 0
	
	for locale_code in local.available_locales.keys():
		var locale_name = local.available_locales[locale_code]
		local_option.add_item(locale_name)
		local_option.set_item_metadata(index, locale_code)
		
		# 检查是否是保存的语言
		if locale_code == saved_language:
			selected_index = index
		
		index += 1
	
	# 设置当前选中的语言
	local_option.selected = selected_index
	
	# 应用保存的语言设置
	if saved_language != "":
		local.change_locale(saved_language)

func _on_language_selected(index: int):
	# 获取选中语言的代码
	var locale_code = local_option.get_item_metadata(index)
	
	# 切换语言
	debug_tool.local.change_locale(locale_code)
	
	# 保存到配置文件
	debug_tool.save_config.set_language(locale_code)