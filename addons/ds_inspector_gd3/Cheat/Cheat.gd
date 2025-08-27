extends VBoxContainer

@export
var cheat_package_scene: PackedScene;
@export
var cheat_list: VBoxContainer = $Scroll/CheatList


func add_cheat_button(title: String, target: Node, method: String):
	var item: Control = cheat_package_scene.instance();
	var t: Label = item.get_node("Title");
	var b: Button = item.get_node("Button");
	t.text = title;
	b.connect("pressed", target, method)
	cheat_list.add_child(item);
