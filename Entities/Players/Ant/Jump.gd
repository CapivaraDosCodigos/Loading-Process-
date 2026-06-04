extends PlayerState

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.velocity.y = -player.jump_velocity
	player.coyote_timer = 0
	player.buffer_jump.set_buffer_time()
	player.animation.play(JUMP)
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true)
	AudioManager.play(AudioGame.PLAYER_SFX_1, Player2D.audio_jump, 40.0)

func physics_update(delta: float) -> void:
	player.handle_movement()
	
	player.apply_gravity(delta)
	
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUN)
	
	elif handle_dash():
		return
	
	elif player.can_wall_slide():
		finished.emit("WallSlide")

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		if player.has_dash:
			finished.emit("Dash")
			return true
		player.buffer_dash.set_buffer_time()
		player.use_skills()
	return false

	
