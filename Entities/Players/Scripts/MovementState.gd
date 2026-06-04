extends PlayerState

func physics_update(delta: float) -> void:
	handle_jump(player)
	
	player.handle_movement()
	
	player.apply_gravity(delta)
	
	if player.is_on_floor():
		player.can_dash = true
	
	if handle_dash():
		return
	
	elif player.can_wall_slide():
		finished.emit()

func handle_dash(player: Player2D)-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		if player.has_dash:
			state_machine.change_state("Dash")
			return true
		player.buffer_dash.set_buffer_time()
		player.use_skills()
	return false

func handle_jump(player: Player2D)-> void:
	if player.buffer_jump.is_interval() and (player.is_on_floor() or player.coyote_timer > 0):
		player.velocity.y = -player.jump_velocity
		player.coyote_timer = 0
		player.buffer_jump.set_buffer_time()
		AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true)
		AudioManager.play(AudioGame.PLAYER_SFX_1, Player2D.audio_jump, 40.0)
