extends PlayerState

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.animation.play(IDLE)

func physics_update(delta: float) -> void:
	if player.is_on_floor():
		player.can_dash = true
	
	player.velocity.y += player.fall_gravity * delta
	player.animation.scale.x = player.direction
	
	if handle_dash():
		return
	
	elif player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)
	
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or !is_equal_approx(player.velocity.x, 0.0):
		finished.emit(RUN)
	
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE)
	
	elif not player.is_on_floor():
		finished.emit("Fall")

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.dash_cooldown:
		if player.has_dash:
			finished.emit("Dash")
			return true
		player.buffer_dash.set_buffer_time()
		player.use_skills()
	return false
