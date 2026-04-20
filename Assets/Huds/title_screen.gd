extends Node

const start_scene_file: String = "uid://dulvyijonmsnp"

@onready var container_buttons: MarginContainer = $ContainerButtons
@onready var container_credits: MarginContainer = $ContainerCredits

func _ready() -> void:
	Global.controls.visible = false
	Global.game_hud.visible = false
	container_buttons.visible = true
	container_credits.visible = false

func _on_start_button_pressed() -> void:
	SceneManager.load_scene(start_scene_file, true, "transition_4")

func _on_credits_button_pressed() -> void:
	container_buttons.visible = false
	container_credits.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_return_button_pressed() -> void:
	container_buttons.visible = true
	container_credits.visible = false
