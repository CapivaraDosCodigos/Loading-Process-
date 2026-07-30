extends PlayerState

var wall_jump_lock: int = 0

func enter(_previous_state_path: String, data: Dictionary = {}) -> void:
	player.animation.play(WALL_JUMP)
	
	var wall_direction: float = 0.0
	wall_direction = data["wall_direction"]
	
	player.velocity = Vector2(
		player.jump_height * wall_direction * 2.0,
		-player.jump_velocity
	)
		
	player.direction = wall_direction
	player.animation.scale.x = player.direction
	
	player.coyote_timer = 0
	player.buffer_jump.set_buffer_time()
	wall_jump_lock = 12
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true)
	AudioManager.play(AudioGame.PLAYER_SFX_1, Player2D.audio_jump, 40.0)

func physics_update(delta: float) -> void:
	handle_movement()
	
	_apply_gravity(delta)
	player.animation.scale.x = player.direction
	
	if wall_jump_lock > 0:
		wall_jump_lock -= 1
	
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUN)
	
	elif handle_dash():
		return
	
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE)
	 
	elif player.velocity.y > 0.0:
		finished.emit(FALL)

func get_name() -> StringName:
	return WALL_JUMP

func handle_movement() -> void:
	var direction_input: float = Game.get_input().x

	if wall_jump_lock > 0:
		return
	
	if direction_input != 0.0:
		player.direction = direction_input
		player.velocity.x = player.direction * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.speed)

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		finished.emit(DASH)
		return true
	return false

func _apply_gravity(delta: float) -> void:
	if player.velocity.y > 0 or !Input.is_action_pressed("ui_accept"):
		player.velocity.y += player.fall_gravity * delta
	else:
		player.velocity.y += player.gravity * delta
