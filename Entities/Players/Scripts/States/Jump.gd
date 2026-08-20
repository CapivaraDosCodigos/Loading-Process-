extends PlayerState

var is_pre_jump: bool = false
var direction_input: float

func enter(_previous_state: String, _data: Dictionary = {}) -> void:
	is_pre_jump = true
	player.animation.play(PRE_JUMP)
	
	await player.animation.animation_finished
	
	player.animation.play(JUMP)
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true)
	AudioManager.play(AudioGame.PLAYER_SFX_1, Player2D.audio_jump, 40.0)
	
	player.velocity.y = -player.jump_velocity
	
	player.coyote_timer = 0
	player.buffer_jump.set_buffer_time()
	
	await player.animation.animation_finished
	
	is_pre_jump = false

func physics_update(delta: float) -> void:
	if is_pre_jump:
		return
	
	handle_movement(delta)
	
	apply_gravity(delta)
	
	player.animation.scale.x = player.direction
	
	if is_zero_approx(player.velocity.y / 10000000.0) or is_zero_approx(player.velocity.y):
		player.animation.play("Jump-Medio")
	
	elif player.velocity.y > 0.0:
		finished.emit(FALL)
	
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUN)
	
	elif handle_dash():
		return
	
	elif can_wall_slide():
		finished.emit(WALL_SLIDE)

func handle_movement(delta: float) -> void:
	direction_input = Inputs.get_input().x
	player.direction = direction_input
	
	if player.velocity.abs().x > player.speed:
		if player.velocity.sign().x != direction_input:
			player.velocity.x = lerp(player.velocity.x, direction_input * player.speed, delta)
		return
	
	player.velocity.x = direction_input * player.speed

func get_name() -> StringName:
	return JUMP

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		finished.emit(DASH)
		return true
	return false

func apply_gravity(delta: float) -> void:
	player.velocity.y += player.gravity * delta
	
	var not_pressed: = not Input.is_action_pressed("ui_accept")
	var just_released: = Input.is_action_just_released("ui_accept")
	
	if (not_pressed or just_released) and player.velocity.y < -player.jump_velocity / 2.0:
		player.velocity.y = -player.jump_velocity / 2.0
