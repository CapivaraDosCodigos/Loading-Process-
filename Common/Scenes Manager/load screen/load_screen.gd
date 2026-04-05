extends CanvasLayer
class_name LoadScreen

signal loading_screen_ready

@export var animation: AnimationPlayer
var type_transition: String = "transition_1"

func _ready() -> void:
	animation.play(type_transition)
	await animation.animation_finished
	loading_screen_ready.emit()
	
func _on_progress_changed(_new_value: float) -> void:
	pass

func _on_load_finished() -> void:
	animation.play_backwards(type_transition)
	await animation.animation_finished
	queue_free()
