@tool
extends EditorPlugin

const panel_scene := preload("res://addons/local-asset-library/panel.tscn")
var panel_instance : MarginContainer

func _enter_tree() -> void:
	panel_instance = panel_scene.instantiate()
	panel_instance.editor_interface = get_editor_interface()
	get_editor_interface().get_editor_main_screen().add_child(panel_instance)
	_make_visible(false)

func _exit_tree() -> void:
	if panel_instance:
		panel_instance.queue_free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible) -> void:
	if panel_instance:
		panel_instance.visible = visible

func _get_plugin_name() -> String:
	return "LocalAssetLib"

func _get_plugin_icon() -> Texture2D:
	return get_editor_interface().get_base_control().get_theme_icon("Object", "EditorIcons")
