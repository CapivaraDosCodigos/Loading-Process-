extends PlayerState

func enter(_previous_state_path: String, _data: Dictionary = {}) -> void:
	player.animation.play(IDLE)

func physics_update(delta: float) -> void:
	if player.is_on_floor():
		player.can_dash = true
	
	player.apply_gravity(delta)
	
	if handle_dash():
		return
	
	elif player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)
	
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		finished.emit(RUN)
	
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
