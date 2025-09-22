# DsInspector

[English](README.md)|[中文](README_zh.md)

**DsInspector（Developer Support Inspector）** 是一个用于 **Godot 4** 的运行时调试插件，允许你在游戏运行时实时查看和修改场景树中的节点和属性。
它提供类似于编辑器 Inspector 的功能，让开发者在调试和测试过程中更加方便直观。

![screenshot](addons/ds_inspector/icon/Icon.png)

## 功能特性

* **实时节点树查看**：显示当前运行场景中的所有节点。
* **节点属性检查**：支持查看和修改节点的属性值（包括脚本导出变量），修改属性后立即生效。
* **节点搜索**：快速查找目标节点。
* **节点选中高亮**：在游戏画面中定位选中的节点，选择“拣选节点”后点击场景内元素即可选择节点，如果元素堆叠，连续点击元素即可依次选中节点。
* **排除路径**：过滤指定路径，方便快速定位节点。
* **打开脚本/场景路径**：在属性面板中可快速打开关联的脚本或在资源管理器中定位场景文件路径，方便跳转查看源文件。
* **将节点保存为场景**：支持将选中的节点导出并保存为新的场景（例如 `.tscn`），便于复用和共享。
* **做弊按钮**：可以通过 `DsInspector.add_cheat_button()` 快速添加做弊按钮。
* **导出自动屏蔽插件**：该插件仅在编辑器运行游戏时生效，导出游戏后自动屏蔽插件所有功能，无需做额外设置。

## 支持版本

本插件针对 Godot 4.2+ 系列开发和测试，不支持更低版本。

如需在Godot3x中使用，请使用该仓库：https://github.com/xlljc/DsInspector_GD3

## 安装方法

1. 将本仓库克隆，并将 `addons/` 复制到你的 Godot 工程的 `addons/` 文件夹下。
2. 在 `project.godot` 中启用插件：

   * 打开 `Project > Project Settings > Plugins`
   * 找到 `DsInspector` 并启用
3. 运行游戏后会自动出现一个悬浮窗口，点击悬浮窗口即可打开检查器。

如果需要插件使用原生Windows窗口，可以在启动游戏时使用以下代码开启：

```gdscript
get_viewport().gui_embed_subwindows = false
```

## 预览

![preview](docs/preview.gif)

![2025-09-22_014424](docs/2025-09-22_014424.png)

![2025-09-22_015110](docs/2025-09-22_015110.png)

## 许可证

本项目使用 **MIT License**。
