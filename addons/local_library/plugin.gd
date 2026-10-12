@tool
extends EditorPlugin

const panel_scene := preload("panel.tscn")
var panel_instance: MarginContainer

func _enter_tree() -> void:
	panel_instance = panel_scene.instantiate()
	EditorInterface.get_editor_main_screen().add_child(panel_instance)
	_make_visible(false)

func _exit_tree() -> void:
	panel_instance.queue_free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	panel_instance.visible = visible

func _get_plugin_name() -> String:
	return "Local Library"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("FileAccess", "EditorIcons")
