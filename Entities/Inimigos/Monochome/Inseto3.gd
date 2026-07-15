extends InimigoGround2D

func _physics_process(delta: float) -> void:
	_gravity(delta)
	
	if is_hurtet:
		return
	
	_apply_movement()

func _apply_movement() -> void:
	var target: Player2D = ManagerGame.player
	if not target:
		return
	
	direction.x = target.global_position.x - global_position.x
	
	if is_on_floor():
		velocity.x = direction.x * speed
	
	move_and_slide()

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
