extends InimigoGround2D

@export var jump: float = 256.0

func _apply_movement() -> void:
	var target: Player2D = ManagerGame.player
	if not target:
		return
	
	direction.x = MathGame.desnormalized(target.global_position - global_position).x
	var distance: float = global_position.direction_to(target.global_position).x
	
	velocity.x = direction.x * speed
	
	if is_on_floor() and !is_zero_approx(distance / 1000.0):
		velocity.y = -jump
		
	#elif is_zero_approx(distance / 1000.0):
		#velocity.x = 0.0
	
	if !is_zero_approx(get_real_velocity().x):
		animated.play("Walking")
	else:
		animated.stop()
	
	move_and_slide()

func _should_flip() -> bool:
	return true

func _apply_flip() -> void:
	if is_zero_approx(direction.x):
		return
	
	if wall_detector:
		wall_detector.scale.x = direction.x * -1.0
	
	if animated:
		animated.scale.x = direction.x * -1.0
	
	elif sprite:
		sprite.scale.x = direction.x * -1.0
