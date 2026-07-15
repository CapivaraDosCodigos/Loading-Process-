extends PlayerState
#class_name WallSlideState

var wall_direction: float = 0.0

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.animation.play("Climbing")

func physics_update(delta: float) -> void:
	player.can_dash = true
	
	player.velocity.y += player.gravity / 4.0 * delta
	
	wall_direction = -1.0 if player.ray_right.is_colliding() else 1.0
	
	if handle_jump():
		finished.emit("WallJump", {"wall_direction": wall_direction})
		return
	
	elif handle_dash():
		return
	
	elif not player.can_wall_slide():
		if player.is_on_floor():
			if is_equal_approx(player.velocity.x, 0.0):
				finished.emit(IDLE)
			else:
				finished.emit(RUN)
		else:
			finished.emit(FALL)
	else: 
		player.direction = wall_direction
		player.animation.scale.x = -player.direction

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.dash_cooldown:
		if player.has_dash:
			player.direction = wall_direction
			player.animation.scale.x = player.direction
			player.animation.play(JUMP)
			finished.emit(DASH)
			
			return true
			
		player.buffer_dash.set_buffer_time()
		player.use_skills()
	
	return false

func handle_jump()-> bool:
	return player.buffer_jump.is_interval()
