extends Resource
class_name InputBuffer

var input: StringName
var interval_time: int = 5
var buffer_time: int = 0

func _init(input_name: StringName = "", interval: int = 0) -> void:
	interval_time = interval
	input = input_name

func update_process() -> void:
	if buffer_time > 0:
		buffer_time -= 1
	
	if input.is_empty():
		return
	
	if Input.is_action_just_pressed(input):
		buffer_time = interval_time

func is_interval() -> bool:
	return buffer_time > 0

func set_buffer_time(value: int = 0) -> void:
	buffer_time = value
