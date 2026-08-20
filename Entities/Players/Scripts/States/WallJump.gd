extends PlayerState

var wall_jump_lock: int = 0
var direction_input: float

func enter(_previous_state_path: String, data: Dictionary = {}) -> void:
	player.animation.play(WALL_JUMP)
	
	var wall_direction: float = 0.0
	wall_direction = data["wall_direction"]
	
	player.velocity = Vector2(
		wall_direction * player.jump_velocity,
		-player.speed
	)
		
	player.direction = wall_direction
	player.animation.scale.x = player.direction
	
	player.coyote_timer = 0
	player.buffer_jump.set_buffer_time()
	wall_jump_lock = 12
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true)
	AudioManager.play(AudioGame.PLAYER_SFX_1, Player2D.audio_jump, 40.0)

func physics_update(delta: float) -> void:
	handle_movement(delta)
	
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
	
	elif can_wall_slide():
		finished.emit(WALL_SLIDE)
	 
	elif player.velocity.y > 0.0:
		finished.emit(FALL)

func get_name() -> StringName:
	return WALL_JUMP

func handle_movement(delta: float) -> void:
	if wall_jump_lock > 0:
		return
	
	direction_input = Inputs.get_input().x
	player.direction = direction_input
	
	if player.velocity.abs().x > player.speed:
		if player.velocity.sign().x != direction_input:
			player.velocity.x = lerp(player.velocity.x, direction_input * player.speed, delta)
		return
	
	player.velocity.x = direction_input * player.speed

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		finished.emit(DASH)
		return true
	return false

func _apply_gravity(delta: float) -> void:
	player.velocity.y += player.gravity * delta
	
	var not_pressed: = not Input.is_action_pressed("ui_accept")
	var just_released: = Input.is_action_just_released("ui_accept")
	
	if (not_pressed or just_released) and player.velocity.y < -player.jump_velocity / 2.0:
		player.velocity.y = -player.jump_velocity / 2.0
