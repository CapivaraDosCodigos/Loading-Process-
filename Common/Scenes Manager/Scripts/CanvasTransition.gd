extends CanvasLayer
class_name CanvasTransition

const transition = "transition"

signal loading_screen_ready

@export var animation: AnimationPlayer
@export var screen: CanvasItem

func _ready() -> void:
	animation.play(transition)
	await animation.animation_finished
	loading_screen_ready.emit()

func set_shader_parameters(parameters: Dictionary[StringName, Variant]) -> void:
	for parameter: StringName in parameters.keys():
		screen.material.set(parameter, parameters[parameter])

func _on_progress_changed(_new_value: float) -> void:
	pass

func _on_load_finished() -> void:
	animation.play_backwards(transition)
	await animation.animation_finished
	queue_free()
