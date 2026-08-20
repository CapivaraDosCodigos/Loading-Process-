@tool
extends EnemyGround2D

@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var jump: float = 256.0

func _apply_movement() -> void:
	var target: Vector2 = Game.player_position
	if target == Vector2.ZERO:
		return
	
	var distance: float = global_position.x - target.x
	
	velocity.x = direction.x * speed
	
	if is_on_floor() and !is_zero_approx(distance / 1000.0):
		velocity.y = -jump
		
	elif is_zero_approx(distance / 1000.0):
		velocity.x = 0.0
	
	if !is_zero_approx(get_real_velocity().x):
		play("Walking")
	else:
		pause()

func _should_flip() -> void:
	pass

func _apply_flips() -> void:
	if is_zero_approx(direction.x):
		return
	
	if wall_detector:
		wall_detector.scale.x = direction.x
	
	if animated:
		animated.scale.x = direction.x
	
	elif sprite:
		sprite.scale.x = direction.x
