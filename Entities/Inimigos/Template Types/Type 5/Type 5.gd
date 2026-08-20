@tool
extends EnemyGround2D

func _apply_movement() -> void:
	var target: Vector2 = Game.player_position
	if target == Vector2.ZERO:
		return
	
	var distance: float = global_position.x - target.x
	direction.x = Vector2(target - global_position).sign().x
	
	if is_on_floor() and ground_detector.is_colliding() and !is_zero_approx(distance / 1000.0):
		velocity.x = direction.x * speed
	else:
		velocity.x = 0.0
	
	if !is_zero_approx(get_real_velocity().x):
		animated.play("Walking")
	else:
		animated.stop()

func _should_flip() -> void:
	if is_on_floor():
		direction.x += -1.0

func _apply_flips() -> void:
	if is_zero_approx(direction.x):
		return
	
	if wall_detector:
		wall_detector.scale.x = direction.x
	
	if ground_detector:
		ground_detector.scale.x = direction.x
	
	if animated:
		animated.scale.x = direction.x
	
	elif sprite:
		sprite.scale.x = direction.x
