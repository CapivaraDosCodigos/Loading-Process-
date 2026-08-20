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

static func create_canvas_transition(transition_scene: String, parameters: Dictionary[StringName, Variant] = {}) -> CanvasTransition:
	if not FileAccess.file_exists(transition_scene):
		push_warning("Nao existe arquivo na path: ", transition_scene)
		return null
	
	var canvas_transition: CanvasTransition
	canvas_transition = load(transition_scene).instantiate()
	
	if not parameters.is_empty():
		canvas_transition.set_shader_parameters(parameters)
	
	return canvas_transition

func set_shader_parameters(parameters: Dictionary[StringName, Variant]) -> void:
	for parameter: StringName in parameters.keys():
		screen.material.set("shader_parameter/" + parameter, parameters[parameter])

func _on_progress_changed(_new_value: float) -> void:
	pass

func _on_load_finished() -> void:
	animation.play_backwards(transition)
	await animation.animation_finished
	queue_free()
