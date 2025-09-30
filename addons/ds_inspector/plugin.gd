@tool
extends EditorPlugin

var debug_tool: Node

func _enter_tree():
	# 添加自动加载场景
	add_autoload_singleton("DsInspector", "res://addons/ds_inspector/DsInspector.gd")
	# 在 EditorPlugin 脚本里
	# var editor_root = get_editor_interface().get_editor_main_screen()
	# var editor_root = get_editor_interface().get_edited_scene_root()
	var editor_root = EditorInterface.get_edited_scene_root()
	debug_tool = load("res://addons/ds_inspector/DsInspectorTool.tscn").instantiate()
	editor_root.add_child(debug_tool)


func _exit_tree():
	# 移除自动加载场景
	remove_autoload_singleton("DsInspector")
	var editor_root = EditorInterface.get_edited_scene_root()
	editor_root.remove_child(debug_tool)
