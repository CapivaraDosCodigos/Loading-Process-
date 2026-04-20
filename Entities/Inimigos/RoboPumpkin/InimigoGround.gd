extends InimigoBase2D
class_name InimigoGround2D

func _stop() -> void:
	set_physics_process(false)
	animated.pause()

func _play() -> void:
	set_physics_process(true)
	animated.play()

func _internal_ready() -> void:
	_internal_flip()

func _internal_flip() -> void:
	direction.x = scale.y * -1.0
	scale.y = 1.0
	rotation = 0.0
	if wall_detector:
		wall_detector.scale.x = direction.x * -1.0
	if animated:
		animated.scale.x = direction.x * -1.0

func _physics_process(delta: float) -> void:
	_gravity(delta)
	
	if is_hurtet:
		return
	
	_movement()
	_flip_direction()
