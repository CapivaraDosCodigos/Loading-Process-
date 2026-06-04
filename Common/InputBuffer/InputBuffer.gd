extends Resource
class_name InputBuffer

@export var input: InputEventAction
@export var interval_time: int = 5

var buffer_time: int = 0

func update_process() -> void:
	if buffer_time > 0:
		buffer_time -= 1
		
	if Input.is_action_just_pressed(input.action):
		buffer_time = interval_time

func is_interval() -> bool:
	return buffer_time > 0

func set_buffer_time(value: int = 0) -> void:
	buffer_time = value
