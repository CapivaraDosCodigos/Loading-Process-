extends Camera2D
class_name CameraEffect2D

@onready var camera_noise: FastNoiseLite = FastNoiseLite.new()

func move_position(to: Vector2, duration: float, from: Vector2 = global_position) -> void:
	var camera_tween: Tween = create_tween()
	camera_tween.tween_method(_set_global_position, from, to, duration)

func snake(duration: float, camera_tween: Tween) -> void:
	if camera_tween:
		camera_tween.parallel().tween_method(_set_camera_snake, 5.0, 1.0, duration)
	else:
		camera_tween = create_tween()
		camera_tween.tween_method(_set_camera_snake, 5.0, 1.0, duration)

func _set_camera_snake(intensity: float) -> void:
	var camera_offset: float = camera_noise.get_noise_1d(Time.get_ticks_msec()) * intensity
	offset.x = camera_offset
	offset.y = camera_offset

func _set_global_position(pos: Vector2) -> void:
	global_position = pos
