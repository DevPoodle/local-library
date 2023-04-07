@tool
extends MarginContainer

var editor_interface : EditorInterface
var directory : DirAccess
var directory_path : String
var file_icon : Texture2D
var folder_icon : Texture2D
var sub_directories : PackedStringArray

func _ready() -> void:
	if !Engine.is_editor_hint():
		queue_free()
		return
	
	file_icon = editor_interface.get_base_control().get_theme_icon("FileBigThumb", "EditorIcons")
	folder_icon = editor_interface.get_base_control().get_theme_icon("FolderBigThumb", "EditorIcons")
	load_directory()
	create_asset_list()

func load_directory() -> void:
	directory_path = editor_interface.get_editor_paths().get_config_dir() + "/local_asset_library"
	if !DirAccess.dir_exists_absolute(directory_path):
		DirAccess.make_dir_absolute(directory_path)
	directory = DirAccess.open(directory_path)
	
func create_addons_assets_directory() -> void:
	var addons_assets_path := "res://addons/assets"
	if !DirAccess.dir_exists_absolute(addons_assets_path):
		DirAccess.make_dir_recursive_absolute(addons_assets_path)

func create_asset_list() -> void:
	$vbox/assets.clear()
	sub_directories.clear()
	
	for sub_directory in directory.get_directories():
		$vbox/assets.add_item(sub_directory, folder_icon)
		sub_directories.append(sub_directory)
	
	for file in directory.get_files():
		$vbox/assets.add_item(file, file_icon)

func copy_directory(from : String, to : String) -> void:
	var copied_directory := DirAccess.open(from)
	DirAccess.make_dir_absolute(to)
	
	for sub_directory in copied_directory.get_directories():
		copy_directory(from + "/" +  sub_directory, to + "/" + sub_directory)
		
	for file in copied_directory.get_files():
		copied_directory.copy(from + "/" + file, to + "/" + file)

func refresh_pressed() -> void:
	create_asset_list()

func asset_selected(index: int) -> void:
	var file_name : String = $vbox/assets.get_item_text(index)
	
	if !sub_directories.has(file_name):
		create_addons_assets_directory()
		var new_asset_path := "res://addons/assets/" + file_name
		if FileAccess.file_exists(new_asset_path):
			print("An asset with the same name already exists. See: " + new_asset_path)
			return
		
		directory.copy(directory_path + "/" + file_name, new_asset_path)
		editor_interface.get_resource_filesystem().scan()
		
	else:
		var new_directory_path := "res://addons/" + file_name
		if DirAccess.dir_exists_absolute(new_directory_path):
			print("A folder with the same name already exists. See: " + new_directory_path)
			return
		
		copy_directory(directory_path + "/" + file_name, new_directory_path)
		editor_interface.get_resource_filesystem().scan()
