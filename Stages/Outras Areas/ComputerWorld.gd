extends Area2D

@onready var texture: Sprite2D = $Texture

@export_file_path("*.tscn*") var world_path: String

func _unhandled_input(event: InputEvent) -> void:
	if get_overlapping_bodies().size() > 0:
		texture.show()
		
		if event.is_action_pressed("Interect"):
			SceneManager.load_scene(world_path, true, "transition_2")
			
	else:
		texture.hide()
