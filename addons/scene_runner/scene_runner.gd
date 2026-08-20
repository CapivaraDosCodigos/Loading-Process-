@tool
extends EditorPlugin

const SETTING_HARNESS_PATH := "scene_runner/harness_scene_path"
const SETTING_SLOT_GROUP := "scene_runner/slot_group_name"
const TMP_SCENE_PATH := "res://addons/scene_runner/.tmp_run_scene.tscn"

var _button: Button

func _enter_tree() -> void:
	_ensure_project_settings()

	_button = Button.new()
	_button.text = "Run"
	_button.tooltip_text = "Instancia a cena atual dentro da cena harness e roda."
	_button.icon = EditorInterface.get_base_control().get_theme_icon("PlayScene", "EditorIcons")
	_button.focus_mode = Control.FOCUS_NONE
	_button.pressed.connect(_on_run_pressed)
	add_control_to_container(CONTAINER_TOOLBAR, _button)

func _exit_tree() -> void:
	if _button:
		remove_control_from_container(CONTAINER_TOOLBAR, _button)
		_button.queue_free()
		_button = null

func _ensure_project_settings() -> void:
	if not ProjectSettings.has_setting(SETTING_HARNESS_PATH):
		ProjectSettings.set_setting(SETTING_HARNESS_PATH, "")
		ProjectSettings.add_property_info({
			"name": SETTING_HARNESS_PATH,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tscn",
		})
	if not ProjectSettings.has_setting(SETTING_SLOT_GROUP):
		ProjectSettings.set_setting(SETTING_SLOT_GROUP, "scene_runner_slot")
	ProjectSettings.save()

func _on_run_pressed() -> void:
	var current_root: Node = EditorInterface.get_edited_scene_root()
	if not current_root:
		push_warning("Scene Runner: nenhuma cena aberta no editor.")
		return

	if current_root.scene_file_path.is_empty():
		push_warning("Scene Runner: salve a cena atual antes de rodar.")
		return
	
	var harness_path: String = ProjectSettings.get_setting(SETTING_HARNESS_PATH, "")
	if harness_path.is_empty() or not ResourceLoader.exists(harness_path):
		push_warning("Scene Runner: configure 'scene_runner/harness_scene_path' em Project Settings.")
		return

	EditorInterface.save_scene()

	var current_instance: Node = (load(current_root.scene_file_path) as PackedScene).instantiate()
	var harness_instance: Node = (load(harness_path) as PackedScene).instantiate()

	var slot_group: String = ProjectSettings.get_setting(SETTING_SLOT_GROUP, "scene_runner_slot")

	var combined_root: Node = harness_instance
	_attach_to_slot(harness_instance, current_instance, slot_group)

	var packed: PackedScene = PackedScene.new()
	if packed.pack(combined_root) != OK:
		push_error("Scene Runner: falha ao empacotar a cena combinada.")
		combined_root.queue_free()
		return

	var save_error: Error = ResourceSaver.save(packed, TMP_SCENE_PATH)
	combined_root.queue_free()

	if save_error != OK:
		push_error("Scene Runner: falha ao salvar a cena temporária (%s)." % save_error)
		return

	EditorInterface.play_custom_scene(TMP_SCENE_PATH)

func _attach_to_slot(parent_root: Node, child_instance: Node, slot_group: String) -> void:
	var slot: Node = _find_slot(parent_root, slot_group)
	slot.add_child(child_instance)
	child_instance.owner = parent_root

func _find_slot(root: Node, slot_group: String) -> Node:
	for child in root.get_children():
		if child.is_in_group(slot_group):
			return child
	return root
