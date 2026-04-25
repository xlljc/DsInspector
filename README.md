# DsInspector

[![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgodotengine.org%2Fasset-library%2Fapi%2Fasset%2F4605&query=%24.version_string&logo=godotengine&label=asset%20library&labelColor=333639)](https://godotengine.org/asset-library/asset/4605)

[English](README.md) | [中文](README_zh.md)

**DsInspector (Developer Support Inspector)** is a **Godot 4** runtime debugging plugin that allows you to **view and modify nodes and properties in the scene tree in real time** while the game is running.
It provides functionality similar to the built-in Editor Inspector, making debugging and testing much more intuitive and convenient.

![screenshot](addons/ds_inspector/icon/Icon.png)

Author's bilibili homepage: https://space.bilibili.com/259437820

## Features

* **Real-time Node Tree View**: Displays all nodes in the currently running scene, allows dragging nodes to move positions. (Only supports 2D scene inspection; 3D scenes are not supported.)
* **Node Property Inspection**: View and modify node property values (including script-exported variables). Changes take effect immediately. Supports property filtering, you can use "|" to split multiple filter conditions.
* **Node Search**: Quickly find target nodes.
* **Node Selection Highlight**: Locate the selected node in the game viewport.
  When "Pick Node" is enabled, click on an element in the scene to select it.
  If elements overlap, repeatedly clicking cycles through them.
* **Record Node Instances**: Drag nodes to the record area, click recorded nodes to quickly jump. Temporarily records nodes, when nodes are destroyed the records are removed.
* **Favorite Paths**: Favorite specified paths, permanently saved, click to jump to the node at that path.
* **Exclude Paths**: Filter out specific node paths, permanently saved, nodes under these paths will not be selected when picking.
* **Frame-by-Frame Execution**: Pause the game and advance it one frame at a time.
* **Open Script/Scene Path**: In the property panel, quickly open the associated script or locate the scene file in the file explorer—making it easy to jump to source files.
* **Save Node as Scene**: Export and save the selected node as a new scene (e.g. `.tscn`), useful for reuse or sharing.
* **Cheat Buttons**: Quickly add custom cheat/debug buttons via `DsInspector.add_cheat_button()`.
* **Auto-Disable on Export**: The plugin is active only when running the game from the editor; all features are automatically disabled in exported builds—no extra setup required.
* **C# Support**: Fully compatible with C# projects.
  The plugin automatically recognizes C# scripts and `[export]` attributes—no extra configuration needed.
* **Run in Godot Editor**: Allows the plugin to run inside the Godot Editor itself, enabling real-time inspection of internal editor nodes.
  This is especially helpful for developing editor plugins (feature not supported in the 3.x version).
* **Multi-language Support**: Can be switched in settings, currently supported languages include: Simplified Chinese (zh), Traditional Chinese (zh_tw), English (en), Spanish (es), Japanese (ja), Russian (ru).

## Supported Versions

This plugin is developed and tested for **Godot 4.2+**.
Older versions are **not supported**.

For Godot 3.x, please use this repository instead:
👉 [https://github.com/xlljc/DsInspector_GD3](https://github.com/xlljc/DsInspector_GD3)

## Installation

1. Clone this repository and copy the `addons/` folder into your project's `addons/` directory.
2. Enable the plugin in your `project.godot` settings:

   * Open **Project > Project Settings > Plugins**
   * Find **DsInspector** and enable it
3. After running the game, a floating window will appear. Click the window to open the inspector.
4. You can also enable or disable the plugin for the editor or the game from **Project → Tools → DsInspector**.

![image4](docs/image4.png)

## Preview

Inspector window:

![img1](docs/img1.png)

![img2](docs/img2.png)

Pick objects in the scene:

![img3](docs/img3.png)

![preview2](docs/preview2.gif)![preview](docs/preview.gif)

Pick Godot editor nodes:

![preview3](docs/preview3.gif)

## C# Projects

In C# projects, you can use the following wrapper class to conveniently add **cheat buttons**.

```c#
using Godot;

/// <summary>
/// Provides static methods for interacting with the DsInspector singleton to add cheat buttons.
/// This class should be used after SceneTree initialization via the <see cref="Init(SceneTree)"/> method.
/// </summary>
public static class CheatManager
{
    private static SceneTree _tree;
    private static Node _dsInspector;
    private static VBoxContainer _cheatVBoxContainer;

    /// <summary>
    /// Initialize CheatManager by passing a SceneTree instance.
    /// </summary>
    public static void Init(SceneTree tree)
    {
        _tree = tree;
        _dsInspector = null;
    }

    private static Node GetDsInspector()
    {
        if (_tree == null)
        {
            GD.PrintErr("CheatManager is not initialized. Please call CheatManager.Init(SceneTree tree) first.");
            return null;
        }
        if (_dsInspector == null)
        {
            var inst = _tree.Root.GetNodeOrNull("DsInspectorTool");
            _dsInspector = inst.Get("cheat").As<Node>();
        }
        return _dsInspector;
    }
    
    private static VBoxContainer GetCheatVBoxContainer()
    {
        if (_cheatVBoxContainer == null)
        {
            var dsInspector = GetDsInspector();
            if (dsInspector != null)
            {
                _cheatVBoxContainer = _dsInspector.Get("cheat_list").As<VBoxContainer>();
            }
        }
        return _cheatVBoxContainer;
    }

    /// <summary>
    /// Add a cheat button to DsInspector (calls GDScript singleton method).
    /// </summary>
    public static void AddCheatButton(string title, Node target, string method)
    {
        var dsInspector = GetDsInspector();
        if (dsInspector != null)
            dsInspector.Call("add_cheat_button", title, target, method);
    }

    /// <summary>
    /// Add a cheat button to DsInspector (via Callable).
    /// </summary>
    public static void AddCheatButtonCallable(string title, Callable callable)
    {
        var dsInspector = GetDsInspector();
        if (dsInspector != null)
            dsInspector.Call("add_cheat_button_callable", title, callable);
    }

    /// <summary>
    /// Add a cheat item to DsInspector.
    /// </summary>
    public static void AddCheatItem(Node item)
    {
        var vboxContainer = GetCheatVBoxContainer();
        if (vboxContainer != null)
            vboxContainer.AddChild(item);
    }
}
```


## License

This project is licensed under the **MIT License**.
