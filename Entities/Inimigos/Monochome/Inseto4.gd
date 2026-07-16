extends InimigoGround2D

func _apply_movement() -> void:
	if is_on_floor() and ground_detector.is_colliding():
		velocity.x = direction.x * speed
		animated.play("Walking")
	else:
		velocity.x = 0.0
		animated.stop()
	
	move_and_slide()

func _should_flip() -> bool:
	if not wall_detector:
		return false
	
	if not ground_detector:
		return false
	
	return (wall_detector.is_colliding() or not ground_detector.is_colliding()) and is_on_floor()

func _apply_flip() -> void:
	direction *= -1.0
	
	if wall_detector:
		wall_detector.scale.x = direction.x * -1.0
	
	if ground_detector:
		ground_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.scale.x = direction.x * -1.0
	
	elif sprite:
		sprite.scale.x = direction.x * -1.0
