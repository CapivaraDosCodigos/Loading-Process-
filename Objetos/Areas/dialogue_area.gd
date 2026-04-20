extends Area2D
class_name DialogueArea

@onready var texture: Sprite2D = $Texture
@export_multiline() var lines: Array[String] = []

func _unhandled_input(event: InputEvent) -> void:
	if get_overlapping_bodies().size() > 0:
		texture.show()
		if event.is_action_pressed("Interect") and not DialogueManager.is_messagem_active:
			texture.hide()
			DialogueManager.start_messagem(global_position, lines)
	else:
		texture.hide()
		if DialogueManager.dialogue_box != null:
			DialogueManager.dialogue_box.queue_free()
			DialogueManager.is_messagem_active = false
