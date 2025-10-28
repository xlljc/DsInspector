@tool
extends Tree
class_name NodeTree

class NodeData:
	var name: String
	var node: Node
	var visible_icon_index: int = -1
	var script_icon_index: int = -1
	var scene_icon_index: int = -1
	var visible: bool = false
	var slot_item: TreeItem = null
	func _init(_node: Node):
		name = _node.name
		node = _node
		pass
class TreeItemData:
	var node_data: NodeData
	var tree_item: TreeItem
	func _init(_node_data: NodeData, _tree_item: TreeItem):
		node_data = _node_data
		tree_item = _tree_item
		pass
class IconMapping:
	var mapping: Dictionary = {
		"Node": "res://addons/ds_inspector/node_icon/Node.svg",
		"AnimationPlayer": "res://addons/ds_inspector/node_icon/AnimationPlayer.svg",
		"AnimationTree": "res://addons/ds_inspector/node_icon/AnimationTree.svg",
		"CodeEdit": "res://addons/ds_inspector/node_icon/CodeEdit.svg",
		"GraphEdit": "res://addons/ds_inspector/node_icon/GraphEdit.svg",
		"GraphNode": "res://addons/ds_inspector/node_icon/GraphNode.svg",
		"MeshInstance3D": "res://addons/ds_inspector/node_icon/MeshInstance3D.svg",
		"Node3D": "res://addons/ds_inspector/node_icon/Node3D.svg",
		"RichTextLabel": "res://addons/ds_inspector/node_icon/RichTextLabel.svg",
		"TileMap": "res://addons/ds_inspector/node_icon/TileMap.svg",
		"Tree": "res://addons/ds_inspector/node_icon/Tree.svg",
		"AcceptDialog": "res://addons/ds_inspector/node_icon/AcceptDialog.svg",
		"AimModifier3D": "res://addons/ds_inspector/node_icon/AimModifier3D.svg",
		"AnimatableBody2D": "res://addons/ds_inspector/node_icon/AnimatableBody2D.svg",
		"AnimatableBody3D": "res://addons/ds_inspector/node_icon/AnimatableBody3D.svg",
		"AnimatedSprite2D": "res://addons/ds_inspector/node_icon/AnimatedSprite2D.svg",
		"AnimatedSprite3D": "res://addons/ds_inspector/node_icon/AnimatedSprite3D.svg",
		"AnimationMixer": "res://addons/ds_inspector/node_icon/AnimationMixer.svg",
		"Area2D": "res://addons/ds_inspector/node_icon/Area2D.svg",
		"Area3D": "res://addons/ds_inspector/node_icon/Area3D.svg",
		"AspectRatioContainer": "res://addons/ds_inspector/node_icon/AspectRatioContainer.svg",
		"AudioListener2D": "res://addons/ds_inspector/node_icon/AudioListener2D.svg",
		"AudioListener3D": "res://addons/ds_inspector/node_icon/AudioListener3D.svg",
		"AudioStreamPlayer": "res://addons/ds_inspector/node_icon/AudioStreamPlayer.svg",
		"AudioStreamPlayer2D": "res://addons/ds_inspector/node_icon/AudioStreamPlayer2D.svg",
		"AudioStreamPlayer3D": "res://addons/ds_inspector/node_icon/AudioStreamPlayer3D.svg",
		"BackBufferCopy": "res://addons/ds_inspector/node_icon/BackBufferCopy.svg",
		"BaseButton": "res://addons/ds_inspector/node_icon/BaseButton.svg",
		"Bone2D": "res://addons/ds_inspector/node_icon/Bone2D.svg",
		"BoneAttachment3D": "res://addons/ds_inspector/node_icon/BoneAttachment3D.svg",
		"BoneConstraint3D": "res://addons/ds_inspector/node_icon/BoneConstraint3D.svg",
		"BoxContainer": "res://addons/ds_inspector/node_icon/BoxContainer.svg",
		"Button": "res://addons/ds_inspector/node_icon/Button.svg",
		"CpuParticles2D": "res://addons/ds_inspector/node_icon/CpuParticles2D.svg",
		"CpuParticles3D": "res://addons/ds_inspector/node_icon/CpuParticles3D.svg",
		"Camera2D": "res://addons/ds_inspector/node_icon/Camera2D.svg",
		"Camera3D": "res://addons/ds_inspector/node_icon/Camera3D.svg",
		"CanvasGroup": "res://addons/ds_inspector/node_icon/CanvasGroup.svg",
		"CanvasItem": "res://addons/ds_inspector/node_icon/CanvasItem.svg",
		"CanvasLayer": "res://addons/ds_inspector/node_icon/CanvasLayer.svg",
		"CanvasModulate": "res://addons/ds_inspector/node_icon/CanvasModulate.svg",
		"CenterContainer": "res://addons/ds_inspector/node_icon/CenterContainer.svg",
		"CharacterBody2D": "res://addons/ds_inspector/node_icon/CharacterBody2D.svg",
		"CharacterBody3D": "res://addons/ds_inspector/node_icon/CharacterBody3D.svg",
		"CheckBox": "res://addons/ds_inspector/node_icon/CheckBox.svg",
		"CheckButton": "res://addons/ds_inspector/node_icon/CheckButton.svg",
		"CollisionObject2D": "res://addons/ds_inspector/node_icon/CollisionObject2D.svg",
		"CollisionObject3D": "res://addons/ds_inspector/node_icon/CollisionObject3D.svg",
		"CollisionPolygon2D": "res://addons/ds_inspector/node_icon/CollisionPolygon2D.svg",
		"CollisionPolygon3D": "res://addons/ds_inspector/node_icon/CollisionPolygon3D.svg",
		"CollisionShape2D": "res://addons/ds_inspector/node_icon/CollisionShape2D.svg",
		"CollisionShape3D": "res://addons/ds_inspector/node_icon/CollisionShape3D.svg",
		"ColorPicker": "res://addons/ds_inspector/node_icon/ColorPicker.svg",
		"ColorPickerButton": "res://addons/ds_inspector/node_icon/ColorPickerButton.svg",
		"ColorRect": "res://addons/ds_inspector/node_icon/ColorRect.svg",
		"ConeTwistJoint3D": "res://addons/ds_inspector/node_icon/ConeTwistJoint3D.svg",
		"ConfirmationDialog": "res://addons/ds_inspector/node_icon/ConfirmationDialog.svg",
		"Container": "res://addons/ds_inspector/node_icon/Container.svg",
		"Control": "res://addons/ds_inspector/node_icon/Control.svg",
		"ConvertTransformModifier3D": "res://addons/ds_inspector/node_icon/ConvertTransformModifier3D.svg",
		"CopyTransformModifier3D": "res://addons/ds_inspector/node_icon/CopyTransformModifier3D.svg",
		"DampedSpringJoint2D": "res://addons/ds_inspector/node_icon/DampedSpringJoint2D.svg",
		"Decal": "res://addons/ds_inspector/node_icon/Decal.svg",
		"DirectionalLight2D": "res://addons/ds_inspector/node_icon/DirectionalLight2D.svg",
		"DirectionalLight3D": "res://addons/ds_inspector/node_icon/DirectionalLight3D.svg",
		"FileDialog": "res://addons/ds_inspector/node_icon/FileDialog.svg",
		"FlowContainer": "res://addons/ds_inspector/node_icon/FlowContainer.svg",
		"FogVolume": "res://addons/ds_inspector/node_icon/FogVolume.svg",
		"FoldableContainer": "res://addons/ds_inspector/node_icon/FoldableContainer.svg",
		"GpuParticles2D": "res://addons/ds_inspector/node_icon/GpuParticles2D.svg",
		"GpuParticles3D": "res://addons/ds_inspector/node_icon/GpuParticles3D.svg",
		"GpuParticlesAttractorBox3D": "res://addons/ds_inspector/node_icon/GpuParticlesAttractorBox3D.svg",
		"GpuParticlesAttractorSphere3D": "res://addons/ds_inspector/node_icon/GpuParticlesAttractorSphere3D.svg",
		"GpuParticlesAttractorVectorField3D": "res://addons/ds_inspector/node_icon/GpuParticlesAttractorVectorField3D.svg",
		"GpuParticlesCollisionBox3D": "res://addons/ds_inspector/node_icon/GpuParticlesCollisionBox3D.svg",
		"GpuParticlesCollisionHeightField3D": "res://addons/ds_inspector/node_icon/GpuParticlesCollisionHeightField3D.svg",
		"GpuParticlesCollisionSdf3D": "res://addons/ds_inspector/node_icon/GpuParticlesCollisionSdf3D.svg",
		"GpuParticlesCollisionSphere3D": "res://addons/ds_inspector/node_icon/GpuParticlesCollisionSphere3D.svg",
		"Generic6DofJoint3D": "res://addons/ds_inspector/node_icon/Generic6DofJoint3D.svg",
		"GeometryInstance3D": "res://addons/ds_inspector/node_icon/GeometryInstance3D.svg",
		"GraphElement": "res://addons/ds_inspector/node_icon/GraphElement.svg",
		"GraphFrame": "res://addons/ds_inspector/node_icon/GraphFrame.svg",
		"GridContainer": "res://addons/ds_inspector/node_icon/GridContainer.svg",
		"GrooveJoint2D": "res://addons/ds_inspector/node_icon/GrooveJoint2D.svg",
		"HBoxContainer": "res://addons/ds_inspector/node_icon/HBoxContainer.svg",
		"HFlowContainer": "res://addons/ds_inspector/node_icon/HFlowContainer.svg",
		"HScrollBar": "res://addons/ds_inspector/node_icon/HScrollBar.svg",
		"HSeparator": "res://addons/ds_inspector/node_icon/HSeparator.svg",
		"HSlider": "res://addons/ds_inspector/node_icon/HSlider.svg",
		"HSplitContainer": "res://addons/ds_inspector/node_icon/HSplitContainer.svg",
		"HttpRequest": "res://addons/ds_inspector/node_icon/HttpRequest.svg",
		"HingeJoint3D": "res://addons/ds_inspector/node_icon/HingeJoint3D.svg",
		"ImporterMeshInstance3D": "res://addons/ds_inspector/node_icon/ImporterMeshInstance3D.svg",
		"ItemList": "res://addons/ds_inspector/node_icon/ItemList.svg",
		"Label": "res://addons/ds_inspector/node_icon/Label.svg",
		"Label3D": "res://addons/ds_inspector/node_icon/Label3D.svg",
		"LightOccluder2D": "res://addons/ds_inspector/node_icon/LightOccluder2D.svg",
		"LightmapGI": "res://addons/ds_inspector/node_icon/LightmapGI.svg",
		"LightmapProbe": "res://addons/ds_inspector/node_icon/LightmapProbe.svg",
		"Line2D": "res://addons/ds_inspector/node_icon/Line2D.svg",
		"LineEdit": "res://addons/ds_inspector/node_icon/LineEdit.svg",
		"LinkButton": "res://addons/ds_inspector/node_icon/LinkButton.svg",
		"LookAtModifier3D": "res://addons/ds_inspector/node_icon/LookAtModifier3D.svg",
		"MarginContainer": "res://addons/ds_inspector/node_icon/MarginContainer.svg",
		"Marker2D": "res://addons/ds_inspector/node_icon/Marker2D.svg",
		"Marker3D": "res://addons/ds_inspector/node_icon/Marker3D.svg",
		"MenuBar": "res://addons/ds_inspector/node_icon/MenuBar.svg",
		"MenuButton": "res://addons/ds_inspector/node_icon/MenuButton.svg",
		"MeshInstance2D": "res://addons/ds_inspector/node_icon/MeshInstance2D.svg",
		"MissingNode": "res://addons/ds_inspector/node_icon/MissingNode.svg",
		"ModifierBoneTarget3D": "res://addons/ds_inspector/node_icon/ModifierBoneTarget3D.svg",
		"MultiMeshInstance2D": "res://addons/ds_inspector/node_icon/MultiMeshInstance2D.svg",
		"MultiMeshInstance3D": "res://addons/ds_inspector/node_icon/MultiMeshInstance3D.svg",
		"MultiplayerSpawner": "res://addons/ds_inspector/node_icon/MultiplayerSpawner.svg",
		"MultiplayerSynchronizer": "res://addons/ds_inspector/node_icon/MultiplayerSynchronizer.svg",
		"NavigationAgent2D": "res://addons/ds_inspector/node_icon/NavigationAgent2D.svg",
		"NavigationAgent3D": "res://addons/ds_inspector/node_icon/NavigationAgent3D.svg",
		"NavigationLink2D": "res://addons/ds_inspector/node_icon/NavigationLink2D.svg",
		"NavigationLink3D": "res://addons/ds_inspector/node_icon/NavigationLink3D.svg",
		"NavigationObstacle2D": "res://addons/ds_inspector/node_icon/NavigationObstacle2D.svg",
		"NavigationObstacle3D": "res://addons/ds_inspector/node_icon/NavigationObstacle3D.svg",
		"NavigationRegion2D": "res://addons/ds_inspector/node_icon/NavigationRegion2D.svg",
		"NavigationRegion3D": "res://addons/ds_inspector/node_icon/NavigationRegion3D.svg",
		"NinePatchRect": "res://addons/ds_inspector/node_icon/NinePatchRect.svg",
		"Node2D": "res://addons/ds_inspector/node_icon/Node2D.svg",
		"OccluderInstance3D": "res://addons/ds_inspector/node_icon/OccluderInstance3D.svg",
		"OmniLight3D": "res://addons/ds_inspector/node_icon/OmniLight3D.svg",
		"OptionButton": "res://addons/ds_inspector/node_icon/OptionButton.svg",
		"Panel": "res://addons/ds_inspector/node_icon/Panel.svg",
		"PanelContainer": "res://addons/ds_inspector/node_icon/PanelContainer.svg",
		"Parallax2D": "res://addons/ds_inspector/node_icon/Parallax2D.svg",
		"ParallaxBackground": "res://addons/ds_inspector/node_icon/ParallaxBackground.svg",
		"ParallaxLayer": "res://addons/ds_inspector/node_icon/ParallaxLayer.svg",
		"Path2D": "res://addons/ds_inspector/node_icon/Path2D.svg",
		"Path3D": "res://addons/ds_inspector/node_icon/Path3D.svg",
		"PathFollow2D": "res://addons/ds_inspector/node_icon/PathFollow2D.svg",
		"PathFollow3D": "res://addons/ds_inspector/node_icon/PathFollow3D.svg",
		"PhysicalBone2D": "res://addons/ds_inspector/node_icon/PhysicalBone2D.svg",
		"PhysicalBone3D": "res://addons/ds_inspector/node_icon/PhysicalBone3D.svg",
		"PhysicalBoneSimulator3D": "res://addons/ds_inspector/node_icon/PhysicalBoneSimulator3D.svg",
		"PhysicsBody2D": "res://addons/ds_inspector/node_icon/PhysicsBody2D.svg",
		"PhysicsBody3D": "res://addons/ds_inspector/node_icon/PhysicsBody3D.svg",
		"PinJoint2D": "res://addons/ds_inspector/node_icon/PinJoint2D.svg",
		"PinJoint3D": "res://addons/ds_inspector/node_icon/PinJoint3D.svg",
		"PointLight2D": "res://addons/ds_inspector/node_icon/PointLight2D.svg",
		"Polygon2D": "res://addons/ds_inspector/node_icon/Polygon2D.svg",
		"Popup": "res://addons/ds_inspector/node_icon/Popup.svg",
		"PopupMenu": "res://addons/ds_inspector/node_icon/PopupMenu.svg",
		"PopupPanel": "res://addons/ds_inspector/node_icon/PopupPanel.svg",
		"ProgressBar": "res://addons/ds_inspector/node_icon/ProgressBar.svg",
		"Range": "res://addons/ds_inspector/node_icon/Range.svg",
		"RayCast2D": "res://addons/ds_inspector/node_icon/RayCast2D.svg",
		"RayCast3D": "res://addons/ds_inspector/node_icon/RayCast3D.svg",
		"ReferenceRect": "res://addons/ds_inspector/node_icon/ReferenceRect.svg",
		"ReflectionProbe": "res://addons/ds_inspector/node_icon/ReflectionProbe.svg",
		"RemoteTransform2D": "res://addons/ds_inspector/node_icon/RemoteTransform2D.svg",
		"RemoteTransform3D": "res://addons/ds_inspector/node_icon/RemoteTransform3D.svg",
		"ResourcePreloader": "res://addons/ds_inspector/node_icon/ResourcePreloader.svg",
		"RetargetModifier3D": "res://addons/ds_inspector/node_icon/RetargetModifier3D.svg",
		"RigidBody2D": "res://addons/ds_inspector/node_icon/RigidBody2D.svg",
		"RigidBody3D": "res://addons/ds_inspector/node_icon/RigidBody3D.svg",
		"RootMotionView": "res://addons/ds_inspector/node_icon/RootMotionView.svg",
		"ScrollContainer": "res://addons/ds_inspector/node_icon/ScrollContainer.svg",
		"ShaderGlobalsOverride": "res://addons/ds_inspector/node_icon/ShaderGlobalsOverride.svg",
		"ShapeCast2D": "res://addons/ds_inspector/node_icon/ShapeCast2D.svg",
		"ShapeCast3D": "res://addons/ds_inspector/node_icon/ShapeCast3D.svg",
		"Skeleton2D": "res://addons/ds_inspector/node_icon/Skeleton2D.svg",
		"Skeleton3D": "res://addons/ds_inspector/node_icon/Skeleton3D.svg",
		"SkeletonIK3D": "res://addons/ds_inspector/node_icon/SkeletonIK3D.svg",
		"SkeletonModifier3D": "res://addons/ds_inspector/node_icon/SkeletonModifier3D.svg",
		"SliderJoint3D": "res://addons/ds_inspector/node_icon/SliderJoint3D.svg",
		"SoftBody3D": "res://addons/ds_inspector/node_icon/SoftBody3D.svg",
		"SpinBox": "res://addons/ds_inspector/node_icon/SpinBox.svg",
		"SplitContainer": "res://addons/ds_inspector/node_icon/SplitContainer.svg",
		"SpotLight3D": "res://addons/ds_inspector/node_icon/SpotLight3D.svg",
		"SpringArm3D": "res://addons/ds_inspector/node_icon/SpringArm3D.svg",
		"SpringBoneCollision3D": "res://addons/ds_inspector/node_icon/SpringBoneCollision3D.svg",
		"SpringBoneCollisionCapsule3D": "res://addons/ds_inspector/node_icon/SpringBoneCollisionCapsule3D.svg",
		"SpringBoneCollisionPlane3D": "res://addons/ds_inspector/node_icon/SpringBoneCollisionPlane3D.svg",
		"SpringBoneCollisionSphere3D": "res://addons/ds_inspector/node_icon/SpringBoneCollisionSphere3D.svg",
		"SpringBoneSimulator3D": "res://addons/ds_inspector/node_icon/SpringBoneSimulator3D.svg",
		"Sprite2D": "res://addons/ds_inspector/node_icon/Sprite2D.svg",
		"Sprite3D": "res://addons/ds_inspector/node_icon/Sprite3D.svg",
		"StaticBody2D": "res://addons/ds_inspector/node_icon/StaticBody2D.svg",
		"StaticBody3D": "res://addons/ds_inspector/node_icon/StaticBody3D.svg",
		"StatusIndicator": "res://addons/ds_inspector/node_icon/StatusIndicator.svg",
		"SubViewport": "res://addons/ds_inspector/node_icon/SubViewport.svg",
		"SubViewportContainer": "res://addons/ds_inspector/node_icon/SubViewportContainer.svg",
		"TabBar": "res://addons/ds_inspector/node_icon/TabBar.svg",
		"TabContainer": "res://addons/ds_inspector/node_icon/TabContainer.svg",
		"TextEdit": "res://addons/ds_inspector/node_icon/TextEdit.svg",
		"TextureButton": "res://addons/ds_inspector/node_icon/TextureButton.svg",
		"TextureProgressBar": "res://addons/ds_inspector/node_icon/TextureProgressBar.svg",
		"TextureRect": "res://addons/ds_inspector/node_icon/TextureRect.svg",
		"TileMapLayer": "res://addons/ds_inspector/node_icon/TileMapLayer.svg",
		"Timer": "res://addons/ds_inspector/node_icon/Timer.svg",
		"TouchScreenButton": "res://addons/ds_inspector/node_icon/TouchScreenButton.svg",
		"VBoxContainer": "res://addons/ds_inspector/node_icon/VBoxContainer.svg",
		"VFlowContainer": "res://addons/ds_inspector/node_icon/VFlowContainer.svg",
		"VScrollBar": "res://addons/ds_inspector/node_icon/VScrollBar.svg",
		"VSeparator": "res://addons/ds_inspector/node_icon/VSeparator.svg",
		"VSlider": "res://addons/ds_inspector/node_icon/VSlider.svg",
		"VSplitContainer": "res://addons/ds_inspector/node_icon/VSplitContainer.svg",
		"VehicleBody3D": "res://addons/ds_inspector/node_icon/VehicleBody3D.svg",
		"VehicleWheel3D": "res://addons/ds_inspector/node_icon/VehicleWheel3D.svg",
		"VideoStreamPlayer": "res://addons/ds_inspector/node_icon/VideoStreamPlayer.svg",
		"Viewport": "res://addons/ds_inspector/node_icon/Viewport.svg",
		"VisibleOnScreenEnabler2D": "res://addons/ds_inspector/node_icon/VisibleOnScreenEnabler2D.svg",
		"VisibleOnScreenEnabler3D": "res://addons/ds_inspector/node_icon/VisibleOnScreenEnabler3D.svg",
		"VisibleOnScreenNotifier2D": "res://addons/ds_inspector/node_icon/VisibleOnScreenNotifier2D.svg",
		"VisibleOnScreenNotifier3D": "res://addons/ds_inspector/node_icon/VisibleOnScreenNotifier3D.svg",
		"VisualInstance3D": "res://addons/ds_inspector/node_icon/VisualInstance3D.svg",
		"VoxelGI": "res://addons/ds_inspector/node_icon/VoxelGI.svg",
		"Window": "res://addons/ds_inspector/node_icon/Window.svg",
		"WorldEnvironment": "res://addons/ds_inspector/node_icon/WorldEnvironment.svg",
		"XRAnchor3D": "res://addons/ds_inspector/node_icon/XRAnchor3D.svg",
		"XRBodyModifier3D": "res://addons/ds_inspector/node_icon/XRBodyModifier3D.svg",
		"XRCamera3D": "res://addons/ds_inspector/node_icon/XRCamera3D.svg",
		"XRController3D": "res://addons/ds_inspector/node_icon/XRController3D.svg",
		"XRFaceModifier3D": "res://addons/ds_inspector/node_icon/XRFaceModifier3D.svg",
		"XRHandModifier3D": "res://addons/ds_inspector/node_icon/XRHandModifier3D.svg",
		"XRNode3D": "res://addons/ds_inspector/node_icon/XRNode3D.svg",
		"XROrigin3D": "res://addons/ds_inspector/node_icon/XROrigin3D.svg"
	}
	func get_icon(node: Node) -> String:
		var cls_name: String = node.get_class()
		if mapping.has(cls_name):
			return mapping[cls_name]
#		print("未知节点：", cls_name)
		if node is Node2D:
			return mapping["Node2D"]
		if node is Control:
			return mapping["Control"]
		if node is Node3D:
			return mapping["Node3D"]
		return mapping["Node"]
		# return "res://addons/ds_inspector/icon/icon_error_sign.png";
		pass
pass

@export
var debug_tool_path: NodePath

@export
var update_time: float = 1  # 更新间隔时间
var _timer: float = 0.0  # 计时器
var _is_show: bool = false
var _init_tree: bool = false  # 是否已初始化树

var _is_in_select_func: bool = false
var _next_frame_index: int = 0
var _next_frame_select: TreeItem = null # 下一帧要选中的item
@onready
var icon_mapping: IconMapping = IconMapping.new()
@onready
var debug_tool = get_node(debug_tool_path)
@onready
var _script_icon: Texture = preload("res://addons/ds_inspector/icon/icon_script.svg")
@onready
var _scene_icon: Texture = preload("res://addons/ds_inspector/icon/icon_play_scene.svg")
@onready
var _visible_icon: Texture = preload("res://addons/ds_inspector/icon/Visible.png")
@onready
var _hide_icon: Texture = preload("res://addons/ds_inspector/icon/Hide.png")

func _ready():
	# 启用拖拽功能
	set_drag_forwarding(_get_drag_data_fw, _can_drop_data_fw, _drop_data_fw)
	
	# 选中item信号
	item_selected.connect(_on_item_selected)
	# item按钮按下信号
	button_clicked.connect(_on_button_pressed)
	# 展开收起节点信号
	item_collapsed.connect(_on_item_collapsed)

func _process(delta):
	if _is_show:
		_timer += delta
		if _timer >= update_time:
			_timer = 0.0
			update_tree()  # 更新树
	if _next_frame_select != null:
		_next_frame_index -= 1
		if _next_frame_index <= 0:
			_next_frame_select.select(0)
			_next_frame_select = null
			ensure_cursor_is_visible()
	pass

# 初始化树
func init_tree():
	_is_show = true

	# 获取场景树的根节点
	var root: Node = get_tree().root

	# 添加根节点到 Tree
	var root_item: TreeItem = create_item()
	root_item.set_text(0, root.name)
	var root_data: NodeData = NodeData.new(root)
	root_item.set_metadata(0, root_data)  # 存储节点引用
	if root is CanvasItem or root is Control:
		root_item.add_button(0, get_visible_icon(root_data.visible))  # 添加显示/隐藏按钮
	
	# 递归添加子节点
	for child in root.get_children(true):
		if debug_tool and child == debug_tool and !Engine.is_editor_hint():
			continue  # 跳过 DsInspectorTool 节点
		create_node_item(child, root_item, true)

# 显示场景树
func show_tree(select_node: Node = null):
	_is_show = true
	if !_init_tree:
		init_tree()
		_init_tree = true
	else:
		update_tree()  # 如果已经初始化，直接更新树
	
	# 定位选中的节点
	if select_node != null and is_instance_valid(select_node):
		call_deferred("locate_selected", select_node)
	else:
		if debug_tool:
			debug_tool.inspector.set_view_node(null)
	pass

# 隐藏场景树
func hide_tree():
	_is_show = false
	pass

# 更新场景树
func update_tree():
	var item: TreeItem = get_root()
	var data: NodeData = item.get_metadata(0)
	if data:
		var root_node: Node = get_tree().root
		if root_node != data.node:
			clear()
			init_tree()
			return
		# 算差异，分出新增、删除、修改的节点
		_update_children(item, data)
		return

	clear()
	init_tree()
	pass

# 删除选中的节点
func delete_selected():
	var item: TreeItem = get_selected()
	if item:
		var data: NodeData = item.get_metadata(0)
		if data:
			var parent: TreeItem = item.get_parent()
			if data.node:
				data.node.queue_free()
			item.free()

			# 刷新场景树
			# _update_children(parent, parent.get_metadata(0))
			return
	pass

# 定位选中的节点
func locate_selected(select_node: Node):
	if select_node == null or !is_instance_valid(select_node):
		if debug_tool:
			debug_tool.inspector.set_view_node(null)
		return
	# print("执行选中节点...")
	var path_arr: Array = []
	# 一路往上找父节点
	var current := select_node
	while current:
		path_arr.push_front(current)
		current = current.get_parent()
	
	_is_in_select_func = true
	# 再展开节点
	var curr_item: TreeItem = null
	var count: int = path_arr.size()
	for i in range(count):
		var node: Node = path_arr[i]
		if curr_item == null:
			curr_item = get_root()
		else: # 一路往下寻找
			var ch := curr_item.get_children()
			var flag: bool = false
			for child_item in ch:
				var node_data: NodeData = child_item.get_metadata(0)
				if !node_data: # 没有数据，错误
					_is_in_select_func = false
					return
				if node_data.node == node:
					flag = true
					if i < count: # 下面还有节点，展开节点
						child_item.collapsed = false
					curr_item = child_item
					break
			
			if !flag: # 找不到，不要再继续往下找了
				break
	
	if curr_item == null:
		_is_in_select_func = false
		return
	var node_data: NodeData = curr_item.get_metadata(0)
	if !node_data:
		print("选择错问题，metadata 为 null！")
	
	_next_frame_index = 1
	_next_frame_select = curr_item;

	_is_in_select_func = false
	pass

# 更新子节点
func _update_children(parent_item: TreeItem, parent_data: NodeData):
	if parent_item.collapsed:
		# 没展开需要判断是否有子节点，并生成占位符
		if parent_data.slot_item == null:
			if parent_data.node.get_child_count() > 0:
				parent_data.slot_item = create_item(parent_item)  # 创建一个子节点项以便展开
			elif parent_item.get_child_count() > 0:
				# 没有子节点了，移除所有子节点
				for item in parent_item.get_children():
					item.free()
		elif parent_data.node.get_child_count() == 0:
			# 没有子节点了，移除所有子节点
			for item in parent_item.get_children():
				item.free()
			parent_data.slot_item = null
		return

	# 获取实际子节点列表（过滤掉 debug_tool）
	var actual_children: Array = []
	for child_node in parent_data.node.get_children(true):
		if debug_tool and child_node == debug_tool and !Engine.is_editor_hint():
			continue
		actual_children.append(child_node)
	
	# 获取现有的 TreeItem 子节点
	var tree_items: Array = parent_item.get_children()
	
	# 逐个对比，找到第一个不匹配的位置
	var mismatch_index: int = -1
	var min_count: int = min(actual_children.size(), tree_items.size())
	
	for i in range(min_count):
		var tree_item: TreeItem = tree_items[i]
		var node_data: NodeData = tree_item.get_metadata(0)
		
		if !node_data or node_data.node != actual_children[i]:
			# 找到第一个不匹配的位置
			mismatch_index = i
			break
		else:
			# 节点匹配，更新显示信息
			node_data.node = actual_children[i]  # 更新引用
			tree_item.set_text(0, actual_children[i].name)
			if node_data.visible_icon_index >= 0:
				node_data.visible = node_data.node.visible
				tree_item.set_button(0, node_data.visible_icon_index, get_visible_icon(node_data.visible))
			
			# 递归更新子节点
			_update_children(tree_item, node_data)
	
	# 如果找到不匹配的位置，或者数量不一致
	if mismatch_index >= 0 or actual_children.size() != tree_items.size():
		# 确定开始删除的位置
		var delete_from: int = mismatch_index if mismatch_index >= 0 else min_count
		
		# 删除从不匹配位置开始的所有 TreeItem
		for i in range(delete_from, tree_items.size()):
			tree_items[i].free()
		
		# 从不匹配位置开始重新创建 TreeItem
		for i in range(delete_from, actual_children.size()):
			create_node_item(actual_children[i], parent_item, true)
	pass


# 创建一个新的 TreeItem
func create_node_item(node: Node, parent: TreeItem, add_slot: bool) -> TreeItem:
	var item: TreeItem = create_item(parent)
	item.collapsed = true
	var node_data = NodeData.new(node)
	item.set_metadata(0, node_data)  # 存储节点引用
	item.set_text(0, node.name)
	if node.name == "PauseMenu":
		print("create: " + node.name)
	# item.set_icon(0, get_icon("Node", "EditorIcons"))
	item.set_icon(0, load(icon_mapping.get_icon(node)))

	var btn_index: int = 0
	if node.scene_file_path != "":
		node_data.scene_icon_index = btn_index
		item.add_button(0, _scene_icon)  # 添场景按钮
		btn_index += 1
	if node.get_script() != null:
		node_data.script_icon_index = btn_index
		item.add_button(0, _script_icon)  # 添加脚本按钮
		btn_index += 1
	if node is CanvasItem or node is Control or node is CanvasLayer:
		node_data.visible_icon_index = btn_index
		node_data.visible = node.visible
		item.add_button(0, get_visible_icon(node_data.visible))  # 添加显示/隐藏按钮
		btn_index += 1
	if add_slot and node.get_child_count(true) > 0:
		var slot = create_item(item)  # 创建一个子节点项以便展开
		node_data.slot_item = slot  # 记录占位符
	return item

## 选中节点
func _on_item_selected():
	# 获取选中的 TreeItem
	var selected_item: TreeItem = get_selected()
	if selected_item:
		# 获取存储的节点引用
		var data: NodeData = selected_item.get_metadata(0)
		if data != null and debug_tool and is_instance_valid(data.node):
			debug_tool.brush.set_draw_node(data.node)
			debug_tool.inspector.set_view_node(data.node)

## 点击按钮节点
func _on_button_pressed(_item: TreeItem, _column: int, _id: int, mouse_button_index: int):
	if !_item:
		return
	# 获取按钮对应的节点
	var data: NodeData = _item.get_metadata(0)
	if data and is_instance_valid(data.node):
		if _id == data.visible_icon_index: # 按下显示/隐藏
			if data.node is CanvasItem or data.node is Control or data.node is CanvasLayer:
				# 切换节点的可见性
				data.visible = !data.node.visible  # 更新可见性状态
				data.node.visible = data.visible
				_item.set_button(0, _id, get_visible_icon(data.visible))  # 更新按钮图标
		elif _id == data.script_icon_index: # 按下脚本图标
			# # 执行 cmd 使用文件管理器打开脚本文件
			# var node_path: String = data.node.get_script().get_path() # 这里返回的路径为  res://path/to/file.gd
			# # 需要先转换路径为资源路径 res://path/to/file.gd -> path/to/file.gd
			var script: Script = data.node.get_script()
			if script:
				var res_path: String = script.get_path()  # 得到 res://path/to/file.gd
				_open_file(res_path)
		elif _id == data.scene_icon_index: # 按下场景按钮
			_open_file(data.node.scene_file_path)
			pass
			
func _open_file(res_path: String):
	var project_root: String = ProjectSettings.globalize_path("res://")
	var file_path: String = res_path.replace("res://", project_root).replace("/", "\\")
	if OS.get_name() == "Windows":
		OS.execute("cmd.exe", ["/c", "explorer.exe /select,\"" + file_path + "\""], [], false)
	elif OS.get_name() == "macOS":
		# 打开指定文件夹
		var mac_path = res_path.replace("res://", project_root)
		# Finder 选中文件
		OS.execute("open", ["-R", mac_path], [], false)

## 展开收起物体
func _on_item_collapsed(item: TreeItem):
	if item.collapsed:
		return
	var data: NodeData = item.get_metadata(0)
	if data != null and data.slot_item != null: # 移除占位符
		item.remove_child(data.slot_item)
		data.slot_item = null
	
	var children := item.get_children()
	if children.size() == 0: # 没有子节点
		if data and data.node.get_child_count(true) > 0: # 加载子节点
			if _is_in_select_func:
				_load_children_item(item)
			else:
				call_deferred("_load_children_item", item)
		return
	var item1 = children[0]
	var child_data: NodeData = item1.get_metadata(0)
	if !child_data: # 没有data，说明没有初始化数据，这里也有加载子节点
		if _is_in_select_func:
			_load_children_item(item)
		else:
			call_deferred("_load_children_item", item)
	else: # 执行更新子节点
		if _is_in_select_func:
			_update_children(item, item.get_metadata(0))
		else:
			call_deferred("_update_children", item, item.get_metadata(0))

func _load_children_item(item: TreeItem, add_slot: bool = true):
	var data: NodeData = item.get_metadata(0)  # 获取存储的节点引用
	if data:
		if !is_instance_valid(data.node): # 节点可能已被删除
			return
		for child in data.node.get_children(true):
			create_node_item(child, item, add_slot)
			
func get_visible_icon(v: bool) -> Texture:
	return _visible_icon if v else _hide_icon

func create_node_data(node: Node) -> NodeData:
	return NodeData.new(node)

# ==================== 拖拽功能实现 ====================


# 执行节点移动操作
# 参数:
#   dragged_node: 被拖拽的节点
#   old_parent: 原父节点
#   target_parent: 目标父节点
#   target_index: 目标索引位置
func _move_node(dragged_node: Node, old_parent: Node, target_parent: Node, target_index: int) -> void:
	# TODO: 在这里实现节点的移除、添加和移动逻辑
	# 提示: 可以使用以下方法:
	old_parent.remove_child(dragged_node)
	target_parent.add_child(dragged_node)
	target_parent.move_child(dragged_node, target_index)
	pass

# 开始拖拽时获取数据
func _get_drag_data_fw(_position: Vector2) -> Variant:
	var selected_item: TreeItem = get_selected()
	if selected_item:
		var data: NodeData = selected_item.get_metadata(0)
		if data and is_instance_valid(data.node):
			# 不允许拖拽根节点
			if data.node == get_tree().root:
				return null
			
			# 创建拖拽预览
			var preview = Label.new()
			preview.text = data.node.name
			set_drag_preview(preview)
			
			# 使用 weakref 来存储节点引用,防止节点被释放后访问
			return {"item": selected_item, "node_ref": weakref(data.node)}
	return null

# 判断是否可以放置
func _can_drop_data_fw(position: Vector2, drag_data: Variant) -> bool:
	if typeof(drag_data) != TYPE_DICTIONARY:
		return false
	
	if !drag_data.has("node_ref") or !drag_data.has("item"):
		return false
	
	# 从 weakref 获取节点
	var node_ref: WeakRef = drag_data["node_ref"]
	var dragged_node = node_ref.get_ref()
	
	# 检查节点是否已被销毁
	if dragged_node == null or !is_instance_valid(dragged_node):
		drop_mode_flags = DROP_MODE_DISABLED
		return false
	
	# 获取目标位置的TreeItem
	var target_item: TreeItem = get_item_at_position(position)
	if !target_item:
		return false
	
	var target_data: NodeData = target_item.get_metadata(0)
	if !target_data or !is_instance_valid(target_data.node):
		return false
	
	var target_node: Node = target_data.node
	
	# 不能拖拽到自己
	if dragged_node == target_node:
		drop_mode_flags = DROP_MODE_DISABLED
		return false
	
	# 不能拖拽到自己的子节点
	if target_node.is_ancestor_of(dragged_node):
		drop_mode_flags = DROP_MODE_DISABLED
		return false
	
	# 不能拖拽根节点
	if dragged_node == get_tree().root:
		drop_mode_flags = DROP_MODE_DISABLED
		return false
	
	# 允许放置在节点上(作为子节点)或节点之间
	drop_mode_flags = DROP_MODE_ON_ITEM | DROP_MODE_INBETWEEN
	return true

# 执行放置操作
func _drop_data_fw(position: Vector2, drag_data: Variant) -> void:
	if typeof(drag_data) != TYPE_DICTIONARY:
		return
	
	if !drag_data.has("node_ref"):
		return
	
	# 从 weakref 获取节点
	var node_ref: WeakRef = drag_data["node_ref"]
	var dragged_node = node_ref.get_ref()
	
	# 检查节点是否已被销毁或正在删除队列中
	if dragged_node == null or !is_instance_valid(dragged_node):
		return
	
	# 保存被拖拽节点的折叠状态
	var selected_item: TreeItem = get_selected()
	var was_collapsed: bool = true
	if selected_item:
		var data: NodeData = selected_item.get_metadata(0)
		if data and data.node == dragged_node:
			was_collapsed = selected_item.collapsed
	
	var target_item: TreeItem = get_item_at_position(position)
	if !target_item:
		return
	
	var target_data: NodeData = target_item.get_metadata(0)
	if !target_data or !is_instance_valid(target_data.node):
		return
	
	var target_node: Node = target_data.node
	var section: int = get_drop_section_at_position(position)
	
	var old_parent: Node = dragged_node.get_parent()
	# 再次检查父节点是否有效
	if !is_instance_valid(old_parent):
		return
	
	var old_index: int = dragged_node.get_index()
	
	# 保存世界坐标信息
	var world_transform_2d: Transform2D
	var world_transform_3d: Transform3D
	var world_position: Vector2
	var has_2d_transform: bool = false
	var has_3d_transform: bool = false
	var has_canvas_layer: bool = false
	
	if dragged_node is Node2D:
		world_transform_2d = dragged_node.global_transform
		has_2d_transform = true
	elif dragged_node is Control:
		world_position = dragged_node.global_position
		has_2d_transform = true
	elif dragged_node is Node3D:
		world_transform_3d = dragged_node.global_transform
		has_3d_transform = true
	elif dragged_node is CanvasLayer:
		has_canvas_layer = true
	
	# 计算目标索引
	var target_parent: Node = null
	var target_index: int = -1
	
	match section:
		-1:  # 放置在目标节点之前
			target_parent = target_node.get_parent()
			if target_parent:
				target_index = target_node.get_index()
		0:   # 放置在目标节点上(作为子节点)
			target_parent = target_node
			target_index = target_parent.get_child_count()
		1:   # 放置在目标节点之后
			target_parent = target_node.get_parent()
			if target_parent:
				target_index = target_node.get_index() + 1
	
	if !target_parent:
		return
	
	# 计算调整后的目标索引
	# target_index = _calculate_drop_index(old_parent, old_index, target_parent, target_index)
	
	# 在移动前再次检查所有节点是否有效(因为节点可能在拖拽过程中被销毁)
	if !is_instance_valid(dragged_node):
		return
	if !is_instance_valid(old_parent) or !is_instance_valid(target_parent):
		return
	
	# 执行节点移动操作
	_move_node(dragged_node, old_parent, target_parent, target_index)
	
	# 恢复世界坐标
	if has_2d_transform:
		if dragged_node is Node2D:
			dragged_node.global_transform = world_transform_2d
		elif dragged_node is Control:
			dragged_node.global_position = world_position
	elif has_3d_transform:
		dragged_node.global_transform = world_transform_3d
	
	# 设置节点的所有者(保持原有的所有者)
	if dragged_node.owner == null and old_parent.owner:
		dragged_node.owner = old_parent.owner
	
	# 更新树显示,传递折叠状态
	call_deferred("_update_tree_after_drop", dragged_node, was_collapsed)

# 拖拽后更新树
func _update_tree_after_drop(moved_node: Node, was_collapsed: bool) -> void:
	if is_instance_valid(moved_node):
		update_tree()
		# 重新选中移动的节点并恢复折叠状态
		call_deferred("_restore_collapsed_state", moved_node, was_collapsed)

# 恢复节点的折叠状态
func _restore_collapsed_state(node: Node, was_collapsed: bool) -> void:
	if !is_instance_valid(node):
		return
	
	# 查找对应的 TreeItem
	var found_item: TreeItem = _find_tree_item_by_node(get_root(), node)
	if found_item:
		found_item.collapsed = was_collapsed
		# 选中节点
		found_item.select(0)
		ensure_cursor_is_visible()

# 递归查找节点对应的 TreeItem
func _find_tree_item_by_node(item: TreeItem, target_node: Node) -> TreeItem:
	if !item:
		return null
	
	var data: NodeData = item.get_metadata(0)
	if data and data.node == target_node:
		return item
	
	# 递归查找子节点
	for child in item.get_children():
		var result = _find_tree_item_by_node(child, target_node)
		if result:
			return result
	
	return null

