extends PlayerState
#class_name WallSlideState

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.animation.play("Climbing")

func physics_update(delta: float) -> void:
	player.can_dash = true
	
	player.velocity.y += player.gravity / 4.0 * delta
	
	player.wall_direction = -1.0 if player.ray_right.is_colliding() else 1.0
	
	if handle_jump():
		return
	
	elif handle_dash():
		return
	
	elif not player.can_wall_slide():
		finished.emit("Run")
		return

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		if player.has_dash:
			player.direction = player.wall_direction
			player.animation.scale.x = player.direction
			player.animation.play("Jump")
			finished.emit("Dash")
			
			return true
			
		player.buffer_dash.set_buffer_time()
		player.use_skills()
	
	return false

func handle_jump()-> bool:
	if player.buffer_jump.is_interval():
		player.velocity = Vector2(
			player.wall_slide_force * player.wall_direction,
			-player.jump_velocity
		)
		
		player.direction = player.wall_direction
		player.animation.scale.x = player.direction
	
		player.coyote_timer = 0
		player.buffer_jump.set_buffer_time()
		player.wall_jump_lock = 12
		
		finished.emit("Jump")
		AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true)
		AudioManager.play(AudioGame.PLAYER_SFX_1, Player2D.audio_jump, 40.0)
		return true
	return false
