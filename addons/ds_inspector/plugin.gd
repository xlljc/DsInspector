@tool
extends EditorPlugin

var debug_tool: Node
var tool_menu: PopupMenu
var save_config: DsSaveConfig

# HTTP服务器相关
var http_server: TCPServer = null
var server_port: int = 6004  # 默认端口
var server_clients: Array = []
var server_timer: Timer = null  # 用于定期检查连接的定时器

func _enter_tree():
	# 启动HTTP服务器
	_start_http_server()
	# 创建工具菜单
	tool_menu = PopupMenu.new()
	tool_menu.add_check_item("在编辑器运行", 0)
	tool_menu.add_check_item("在游戏中运行", 1)
	tool_menu.add_item("打开脚本", 2)
	tool_menu.add_item("打开场景", 3)

	DsSaveConfig.save_path = "user://ds_inspector_editor_config.json"
	# 设置初始状态
	save_config = DsSaveConfig.new()
	add_child(save_config)

	tool_menu.set_item_checked(0, save_config.get_enable_in_editor())
	tool_menu.set_item_checked(1, save_config.get_enable_in_game())

	# 连接信号
	tool_menu.connect("id_pressed", Callable(self, "_on_tool_menu_pressed"))

	# 添加到工具菜单
	add_tool_submenu_item("DsInspector", tool_menu)

	_refresh_debug_tool(save_config.get_enable_in_editor())
	_refresh_debug_tool_in_game(save_config.get_enable_in_game())

func _exit_tree():
	# 停止HTTP服务器
	_stop_http_server()
	
	remove_tool_menu_item("DsInspector")
	if save_config.get_enable_in_game():
		remove_autoload_singleton("DsInspector")
	if debug_tool != null:
		debug_tool.free()
		debug_tool = null

func _on_tool_menu_pressed(id: int):
	if id == 0: # 启用编辑器运行
		var enabled = not save_config.get_enable_in_editor()
		save_config.set_enable_in_editor(enabled)
		tool_menu.set_item_checked(0, enabled)
		_refresh_debug_tool(enabled)
	elif id == 1: # 启用游戏中运行
		var enabled = not save_config.get_enable_in_game()
		save_config.set_enable_in_game(enabled)
		tool_menu.set_item_checked(1, enabled)
		_refresh_debug_tool_in_game(enabled)
	elif id == 2: # 打开脚本
		_on_open_script_btn_pressed()
	elif id == 3: # 打开场景
		_on_open_scene_btn_pressed()

func _refresh_debug_tool(enabled: bool):
	if enabled:
		if debug_tool != null:
			debug_tool.free()
		debug_tool = load("res://addons/ds_inspector/DsInspectorTool.tscn").instantiate()
		debug_tool.save_config = save_config
		add_child(debug_tool)
	else:
		if debug_tool != null:
			debug_tool.free()
			debug_tool = null

func _refresh_debug_tool_in_game(enabled: bool):
	if enabled:
		# 添加自动加载场景
		add_autoload_singleton("DsInspector", "res://addons/ds_inspector/DsInspector.gd")
	else:
		# 移除自动加载场景
		remove_autoload_singleton("DsInspector")

func _on_open_script_btn_pressed():
	print("打开脚本")
	# 测试打开一个脚本
	var script: Script = preload("res://addons/ds_inspector/DsInspector.gd")

	get_editor_interface().edit_resource(script)
	print("打开脚本成功")
	pass

func _on_open_scene_btn_pressed():
	print("打开场景")
	# 测试打开一个场景
	get_editor_interface().open_scene_from_path("res://addons/ds_inspector/DsInspectorTool.tscn")
	print("打开场景成功")
	pass

## ==================== HTTP服务器相关 ====================

## 启动HTTP服务器
func _start_http_server():
	if http_server != null:
		return
	
	http_server = TCPServer.new()
	var err = http_server.listen(server_port, "127.0.0.1")
	if err != OK:
		print("DsInspector: 无法启动HTTP服务器，端口 ", server_port, " 可能已被占用")
		http_server = null
		return
	
	print("DsInspector: HTTP服务器已启动，监听端口 ", server_port)
	
	# 创建定时器定期检查新连接
	# 由于EditorPlugin没有_process，我们使用Timer节点
	if server_timer == null:
		server_timer = Timer.new()
		server_timer.wait_time = 0.1  # 每100ms检查一次
		server_timer.timeout.connect(_check_server_connections)
		server_timer.autostart = true
		add_child(server_timer)
	
	# 立即检查一次
	_check_server_connections()

## 停止HTTP服务器
func _stop_http_server():
	# 停止定时器
	if server_timer != null:
		server_timer.queue_free()
		server_timer = null
	
	if http_server != null:
		http_server.stop()
		http_server = null
		# 关闭所有客户端连接
		for client in server_clients:
			if client != null:
				client.disconnect_from_host()
		server_clients.clear()
		print("DsInspector: HTTP服务器已停止")

## 检查服务器连接
func _check_server_connections():
	if http_server == null:
		return
	
	# 接受新连接
	if http_server.is_connection_available():
		var client = http_server.take_connection()
		if client != null:
			server_clients.append(client)
	
	# 处理现有客户端
	var clients_to_remove = []
	for i in range(server_clients.size()):
		var client = server_clients[i]
		if client == null:
			clients_to_remove.append(i)
			continue
		
		# 检查连接状态
		var status = client.get_status()
		if status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
			clients_to_remove.append(i)
			continue
		
		# 检查是否有数据可读
		var available_bytes = client.get_available_bytes()
		if available_bytes > 0:
			_handle_client_request(client)
			# 处理完请求后关闭连接
			clients_to_remove.append(i)
	
	# 移除已断开的客户端
	for i in range(clients_to_remove.size() - 1, -1, -1):
		var idx = clients_to_remove[i]
		if idx < server_clients.size():
			var client = server_clients[idx]
			if client != null:
				client.disconnect_from_host()
			server_clients.remove_at(idx)

## 处理客户端请求
func _handle_client_request(client: StreamPeerTCP):
	if client == null:
		return
	
	var available_bytes = client.get_available_bytes()
	if available_bytes <= 0:
		return
	
	# 读取HTTP请求（限制最大读取大小，避免内存问题）
	var max_read = min(available_bytes, 4096)
	var request_data = client.get_data(max_read)
	if request_data[0] != OK:
		return
	
	var request_text = request_data[1].get_string_from_utf8()
	if request_text.is_empty():
		return
	
	# 解析HTTP请求
	var lines = request_text.split("\n")
	if lines.size() == 0:
		return
	
	var request_line = lines[0].strip_edges()
	var parts = request_line.split(" ", false)
	if parts.size() < 2:
		return
	
	var method = parts[0]
	var path = parts[1]
	
	# 处理不同的请求路径
	var response_text = ""
	if method == "GET" or method == "POST":
		if path.begins_with("/open_script?"):
			# 解析查询参数
			var query = path.substr("/open_script?".length())
			var params = _parse_query_string(query)
			var script_path = params.get("path", "")
			if not script_path.is_empty():
				_open_script_in_editor(script_path)
				response_text = "HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: 2\r\n\r\nOK"
			else:
				response_text = "HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: 20\r\n\r\nMissing path parameter"
		elif path.begins_with("/open_scene?"):
			# 解析查询参数
			var query = path.substr("/open_scene?".length())
			var params = _parse_query_string(query)
			var scene_path = params.get("path", "")
			if not scene_path.is_empty():
				_open_scene_in_editor(scene_path)
				response_text = "HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: 2\r\n\r\nOK"
			else:
				response_text = "HTTP/1.1 400 Bad Request\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: 20\r\n\r\nMissing path parameter"
		else:
			response_text = "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: 9\r\n\r\nNot Found"
	else:
		response_text = "HTTP/1.1 405 Method Not Allowed\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: 18\r\n\r\nMethod Not Allowed"
	
	# 发送响应
	if not response_text.is_empty():
		var response_bytes = response_text.to_utf8_buffer()
		client.put_data(response_bytes)

## 解析查询字符串
func _parse_query_string(query: String) -> Dictionary:
	var params = {}
	var pairs = query.split("&")
	for pair in pairs:
		var key_value = pair.split("=")
		if key_value.size() == 2:
			var key = key_value[0].uri_decode()
			var value = key_value[1].uri_decode()
			params[key] = value
	return params

## 在编辑器中打开脚本
func _open_script_in_editor(script_path: String):
	if script_path.is_empty():
		print("DsInspector: 脚本路径为空")
		return
	
	# URL解码
	script_path = script_path.uri_decode()
	
	var script: Script = load(script_path)
	if script == null:
		print("DsInspector: 无法加载脚本: ", script_path)
		return
	
	call_deferred("_do_open_script", script)
	print("DsInspector: 请求打开脚本: ", script_path)

func _do_open_script(script: Script):
	get_editor_interface().edit_resource(script)

## 在编辑器中打开场景
func _open_scene_in_editor(scene_path: String):
	if scene_path.is_empty():
		print("DsInspector: 场景路径为空")
		return
	
	# URL解码
	scene_path = scene_path.uri_decode()
	
	call_deferred("_do_open_scene", scene_path)
	print("DsInspector: 请求打开场景: ", scene_path)

func _do_open_scene(scene_path: String):
	get_editor_interface().open_scene_from_path(scene_path)

## 获取服务器端口（供游戏进程使用）
static func get_server_port() -> int:
	# 返回默认端口，如果需要可以从配置文件读取
	return 6004