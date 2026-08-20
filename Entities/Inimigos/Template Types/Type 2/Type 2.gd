@tool
extends EnemyGround2D

func _apply_movement() -> void:
	if is_on_floor() and ground_detector.is_colliding():
		velocity.x = direction.x * speed
		play("Walking")
	else:
		velocity.x = 0.0
		pause()

func _should_flip() -> void:
	if not (wall_detector or ground_detector):
		return
	
	elif (wall_detector.is_colliding() or not ground_detector.is_colliding()) and is_on_floor():
		direction *= -1.0

func _apply_flips() -> void:
	if wall_detector:
		wall_detector.scale.x = direction.x
	
	if ground_detector:
		ground_detector.scale.x = direction.x
	
	if animated:
		animated.scale.x = direction.x
	
	elif sprite:
		sprite.scale.x = direction.x
