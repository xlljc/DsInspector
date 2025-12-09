extends Node

var debug_tool: Node;

@onready
var template: PackedScene = preload("res://addons/ds_inspector/DsInspectorTool.tscn")

# HTTP客户端相关
var http_client: HTTPRequest = null
var editor_server_port: int = 6004  # 编辑器服务器端口
var editor_server_host: String = "127.0.0.1"

func _ready():
	if !OS.has_feature("editor"): # 判断是否是导出模式
		return
	debug_tool = template.instantiate()
	call_deferred("_deff_init")
	_setup_http_client()
	pass

func _deff_init():
	get_parent().add_child(debug_tool)
	reparent(debug_tool)
	pass

### 添加作弊按钮
func add_cheat_button(title: String, target: Node, method: String):
	if debug_tool == null:
		return
	debug_tool.cheat.add_cheat_button(title, target, method)
	pass

### 添加作弊按钮
func add_cheat_button_callable(title: String, callable: Callable):
	if debug_tool == null:
		return
	debug_tool.cheat.add_cheat_button_callable(title, callable)
	pass

## ==================== HTTP客户端相关 ====================

## 设置HTTP客户端
func _setup_http_client():
	if http_client != null:
		return
	
	http_client = HTTPRequest.new()
	add_child(http_client)
	http_client.request_completed.connect(_on_http_request_completed)

## HTTP请求完成回调
func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("DsInspector: HTTP请求失败，错误代码: ", result)
		return
	
	if response_code != 200:
		print("DsInspector: HTTP请求返回错误状态码: ", response_code)
		return
	
	# 请求成功
	# print("DsInspector: HTTP请求成功")

## 请求在编辑器中打开脚本
func request_open_script(script_path: String):
	if !OS.has_feature("editor"):
		print("DsInspector: 警告: 仅在编辑器模式下可以打开脚本")
		return
	
	if http_client == null:
		_setup_http_client()
	
	if http_client == null:
		print("DsInspector: 错误: 无法创建HTTP客户端")
		return
	
	# 构建URL
	var url = "http://%s:%d/open_script?path=%s" % [editor_server_host, editor_server_port, script_path.uri_encode()]
	
	# 发送HTTP请求
	var error = http_client.request(url)
	if error != OK:
		print("DsInspector: 发送HTTP请求失败，错误代码: ", error)

## 请求在编辑器中打开场景
func request_open_scene(scene_path: String):
	if !OS.has_feature("editor"):
		print("DsInspector: 警告: 仅在编辑器模式下可以打开场景")
		return
	
	if http_client == null:
		_setup_http_client()
	
	if http_client == null:
		print("DsInspector: 错误: 无法创建HTTP客户端")
		return
	
	# 构建URL
	var url = "http://%s:%d/open_scene?path=%s" % [editor_server_host, editor_server_port, scene_path.uri_encode()]
	
	# 发送HTTP请求
	var error = http_client.request(url)
	if error != OK:
		print("DsInspector: 发送HTTP请求失败，错误代码: ", error)
