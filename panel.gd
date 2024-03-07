@tool
extends MarginContainer

var editor_interface : EditorInterface
var directory : DirAccess
var directory_path : String
var file_icon : Texture2D
var folder_icon : Texture2D

func _ready() -> void:
	if !Engine.is_editor_hint():
		queue_free()
		return
	
	load_directory()
	create_addons_assets_directory()
	create_asset_tree()

func _notification(notification: int) -> void:
	if notification == NOTIFICATION_THEME_CHANGED and Engine.is_editor_hint():
		file_icon = editor_interface.get_base_control().get_theme_icon("FileBigThumb", "EditorIcons")
		folder_icon = editor_interface.get_base_control().get_theme_icon("FolderBigThumb", "EditorIcons")

func load_directory() -> void:
	directory_path = editor_interface.get_editor_paths().get_config_dir() + "/local_library"
	if !DirAccess.dir_exists_absolute(directory_path):
		DirAccess.make_dir_absolute(directory_path)
	directory = DirAccess.open(directory_path)
	
func create_addons_assets_directory() -> void:
	var addons_assets_path := "res://addons/assets"
	if !DirAccess.dir_exists_absolute(addons_assets_path):
		DirAccess.make_dir_recursive_absolute(addons_assets_path)

func create_asset_tree() -> void:
	$VBox/HBox/Add.disabled = true
	$VBox/FileTree.clear()
	var tree_root : TreeItem = $VBox/FileTree.create_item()
	tree_root.set_text(0, "Root")
	copy_directory_to_tree(tree_root, directory_path)

func copy_directory_to_tree(tree_root: TreeItem, copied_directory_path: String) -> void:
	var copied_directory := DirAccess.open(copied_directory_path)
	
	for sub_directory in copied_directory.get_directories():
		var new_tree_root := tree_root.create_child()
		new_tree_root.set_text(0, sub_directory)
		new_tree_root.set_icon(0, folder_icon)
		new_tree_root.set_icon_max_width(0, 44)
		new_tree_root.set_collapsed_recursive(true)
		new_tree_root.set_metadata(0, "d" + copied_directory_path + "/" + sub_directory)
		copy_directory_to_tree(new_tree_root, copied_directory_path + "/" + sub_directory)
	
	for file in copied_directory.get_files():
		var new_tree_item := tree_root.create_child()
		new_tree_item.set_text(0, file)
		new_tree_item.set_icon(0, file_icon)
		new_tree_item.set_icon_max_width(0, 44)
		new_tree_item.set_metadata(0, "f" + copied_directory_path + "/" + file)

func copy_directory(from: String, to: String) -> void:
	var copied_directory := DirAccess.open(from)
	DirAccess.make_dir_absolute(to)
	
	for sub_directory in copied_directory.get_directories():
		copy_directory(from + "/" +  sub_directory, to + "/" + sub_directory)
		
	for file in copied_directory.get_files():
		copied_directory.copy(from + "/" + file, to + "/" + file)

func add_items_pressed():
	create_addons_assets_directory()
	
	var selected_item : TreeItem = $VBox/FileTree.get_next_selected(null)
	while selected_item != null:
		var file_path : String = selected_item.get_metadata(0)
		
		if file_path[0] == "d":
			copy_directory(file_path.lstrip("d"), "res://addons/" + selected_item.get_text(0))
		elif file_path[0] == "f":
			file_path.erase(0)
			directory.copy(file_path.lstrip("f"), "res://addons/assets/" + selected_item.get_text(0))
			
		selected_item = $VBox/FileTree.get_next_selected(selected_item)
	
	editor_interface.get_resource_filesystem().scan()

func folder_pressed() -> void:
	OS.shell_open(editor_interface.get_editor_paths().get_config_dir() + "/local_library")

func refresh_pressed() -> void:
	create_asset_tree()

func file_tree_cell_selected():
	$VBox/HBox/Add.disabled = false
