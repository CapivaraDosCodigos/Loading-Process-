extends InimigoBase2D
class_name InimigoGround2D

func _stop() -> void:
	set_physics_process(false)
	animated.pause()

func _play() -> void:
	set_physics_process(true)
	animated.play()

func _physics_process(delta: float) -> void:
	if _is_hurt_velocity():
		return
	
	_gravity(delta)
	_movement(delta)
	_flip_direction()
