extends InimigoBase2D
class_name InimigoGround2D

func _stop() -> void:
	set_physics_process(false)
	animated.pause()

func _play() -> void:
	set_physics_process(true)
	animated.play()

func _internal_ready() -> void:
	direction.x = scale.y * -1.0
	scale.y = 1.0
	rotation = 0.0
	if wall_detector:
		wall_detector.scale.x = direction.x * -1.0
	if animated:
		animated.flip_h = direction.x == 1.0

func _physics_process(delta: float) -> void:
	if _is_hurt_velocity():
		return
	
	_gravity(delta)
	_movement()
	_flip_direction()
