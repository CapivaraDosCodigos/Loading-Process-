@tool
extends EnemyGround2D

func _apply_movement() -> void:
	var target: Vector2 = ManagerGame.player_position
	if target == Vector2.ZERO:
		return
	
	direction.x = MathGame.desnormalized(target - global_position).x
	
	var distance: float = global_position.direction_to(global_position).x
	
	if is_on_floor() and !is_zero_approx(distance / 1000.0):
		velocity.x = direction.x * speed
	else:
		velocity.x = 0.0
	
	if !is_zero_approx(get_real_velocity().x):
		play("Walking")
	else:
		animated.stop()

func _should_flip() -> bool:
	return is_on_floor()

func _apply_flip() -> void:
	if is_zero_approx(direction.x):
		return
	
	if wall_detector:
		wall_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.scale.x = direction.x * -1.0
	
	elif sprite:
		sprite.scale.x = direction.x * -1.0
