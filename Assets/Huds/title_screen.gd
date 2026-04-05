extends Control

const start_scene_file: String = "uid://dulvyijonmsnp"

func _on_start_button_pressed() -> void:
	SceneManager.load_scene(start_scene_file, true, "transition_4")

func _on_credits_button_pressed() -> void:
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	get_tree().quit()
