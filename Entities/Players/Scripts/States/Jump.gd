extends PlayerState

var dash_velocity_add: Vector2
var pre_jump: bool = false

func enter(_previous_state: String, data: Dictionary = {}) -> void:
	if data.has("velocity_add"):
		dash_velocity_add = data["velocity_add"]
	
	pre_jump = true
	player.animation.play(PRE_JUMP)
	
	await player.animation.animation_finished
	
	player.animation.play(JUMP)
	
	AudioManager.set_loop(AudioGame.PLAYER_SFX_1, false).set_pitch_random(true)
	AudioManager.play(AudioGame.PLAYER_SFX_1, Player2D.audio_jump, 40.0)
	
	player.velocity.y = -player.jump_velocity
	player.coyote_timer = 0
	player.buffer_jump.set_buffer_time()
	
	await player.animation.animation_finished
	
	pre_jump = false

func physics_update(delta: float) -> void:
	if pre_jump:
		return
	
	handle_movement()
	
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
	
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE)

func handle_movement() -> void:
	var direction_input: float = Inputs.get_input().x
	
	var velocity_add: Vector2 = Vector2.ZERO
	
	if MathGame.desnormalized(dash_velocity_add).x == direction_input:
		velocity_add.x = dash_velocity_add.abs().x
		
	dash_velocity_add = dash_velocity_add.lerp(Vector2.ZERO, player.AIR_FRICTION / 10.0)
	
	if not player.is_on_floor() and dash_velocity_add == Vector2.ZERO:
		player.velocity.x = 0.0
	
	if direction_input != 0.0:
		player.direction = direction_input
		player.velocity.x = player.direction * max(player.speed, velocity_add.x)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.speed)

func get_name() -> StringName:
	return JUMP

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.can_dash and player.dash_cooldown:
		finished.emit(DASH)
		return true
	return false

func apply_gravity(delta: float) -> void:
	if player.velocity.y > 0 or !Input.is_action_pressed("ui_accept"):
		player.velocity.y += player.fall_gravity * delta
	else:
		player.velocity.y += player.gravity * delta
