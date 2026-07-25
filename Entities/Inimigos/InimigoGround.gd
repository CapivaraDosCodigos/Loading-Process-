extends InimigoBase2D
class_name InimigoGround2D

@export var wall_detector: RayCast2D
@export var ground_detector: RayCast2D

func _stop() -> void:
	set_physics_process(false)
	animated.pause()

func _play() -> void:
	set_physics_process(true)
	animated.play()

func _internal_flip() -> void:
	direction.x = scale.y * -1.0
	scale.y = 1.0
	rotation = 0.0
	
	if wall_detector:
		wall_detector.scale.x = direction.x * -1.0
	
	if ground_detector:
		ground_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.scale.x = direction.x * -1.0
	
	elif sprite:
		sprite.scale.x = direction.x * -1.0

func _physics_process(delta: float) -> void:
	_gravity(delta)
	
	if not (is_hurtet or is_stun):
		_apply_movement()
		
		if _should_flip():
			_apply_flip()
	else:
		velocity.x = 0.0
	
	move_and_slide()

func _apply_movement() -> void:
	if is_on_floor():
		velocity.x = direction.x * speed

func _should_flip() -> bool:
	if not wall_detector:
		return false
	
	return wall_detector.is_colliding() and is_on_floor()

func _apply_flip() -> void:
	direction *= -1.0
	wall_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.scale.x = direction.x * -1.0
	
	elif sprite:
		sprite.scale.x = direction.x * -1.0
